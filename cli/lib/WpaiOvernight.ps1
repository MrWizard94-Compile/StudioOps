# Overnight arm / start with mid-loop cost model v0 (round-sliced).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-WpaiOvernightPlanPath {
    return (Join-Path (Get-WpaiConfigValue -Name 'wpai_dir' -Default 'C:\WPAI\Workspace\.wpai') 'overnight-plan.json')
}

function Read-WpaiOvernightPlan {
    $path = Get-WpaiOvernightPlanPath
    if (-not (Test-Path -LiteralPath $path)) {
        return [pscustomobject]@{
            armed = $false; parent_task_ids = @(); max_rounds = 10
        }
    }
    return (Read-WpaiJsonFile -Path $path)
}

function Set-WpaiOvernightArm {
    param(
        [Parameter(Mandatory)][string[]]$ParentTaskIds,
        [int]$MaxRounds = 10,
        [string]$ArmedBy = 'director',
        [int]$ExpiresHours = 18
    )
    if (-not $ParentTaskIds -or $ParentTaskIds.Count -eq 0) {
        throw 'At least one parent_task_id required to arm overnight'
    }
    if ($ParentTaskIds.Count -gt 1) {
        # sequential only — store all but run one at a time
    }
    $now = Get-Date
    $plan = [ordered]@{
        schema_version  = '1.0.0'
        armed           = $true
        parent_task_ids = @($ParentTaskIds)
        max_rounds      = $MaxRounds
        armed_by        = $ArmedBy
        armed_at        = $now.ToUniversalTime().ToString('o')
        expires_at      = $now.AddHours($ExpiresHours).ToUniversalTime().ToString('o')
    }
    Write-WpaiJsonAtomic -Path (Get-WpaiOvernightPlanPath) -Object $plan

    Invoke-WpaiBlackboardRmw -Mutator {
        param($bb)
        $bb['overnight'] = [ordered]@{
            armed           = $true
            parent_task_ids = @($ParentTaskIds)
            max_rounds      = $MaxRounds
            armed_by        = $ArmedBy
            armed_at        = $plan['armed_at']
            expires_at      = $plan['expires_at']
            last_run        = $null
        }
        Add-WpaiEvent -Blackboard $bb -Kind 'overnight' -StepKey 'overnight.arm' -Actor $ArmedBy -Refs @{
            parent_task_ids = ($ParentTaskIds -join ',')
        }
    } | Out-Null

    return $plan
}

function Clear-WpaiOvernightArm {
    param([string]$Reason = 'disarm')
    $plan = [ordered]@{
        schema_version  = '1.0.0'
        armed           = $false
        parent_task_ids = @()
        max_rounds      = 10
        armed_by        = $null
        armed_at        = $null
        expires_at      = $null
        last_disarm     = (Get-WpaiUtcNow)
        disarm_reason   = $Reason
    }
    Write-WpaiJsonAtomic -Path (Get-WpaiOvernightPlanPath) -Object $plan
    Invoke-WpaiBlackboardRmw -Mutator {
        param($bb)
        if ($bb['overnight'] -is [System.Collections.IDictionary]) {
            $bb['overnight']['armed'] = $false
            $bb['overnight']['parent_task_ids'] = @()
        }
        Add-WpaiEvent -Blackboard $bb -Kind 'overnight' -StepKey 'overnight.disarm' -Actor 'director' -Refs @{ reason = $Reason }
    } | Out-Null
    return $plan
}

function Start-WpaiOvernight {
    <#
    .SYNOPSIS
      Round-sliced overnight: for each armed parent, run janus loop with --max-rounds 1
      repeatedly until max_rounds or budget/kill abort. Never multi-round without mid-loop accounting.
    #>
    param(
        [switch]$DryRun
    )
    $bb = Get-WpaiBlackboard
    if (Test-WpaiKillActive -Blackboard $bb -Kind 'loops') {
        throw 'Kill switch active (global or loops) — overnight refused'
    }
    if (Test-WpaiKillActive -Blackboard $bb -Kind 'global') {
        throw 'Global kill switch active — overnight refused'
    }

    $plan = Read-WpaiOvernightPlan
    if (-not $plan.armed) { throw 'Overnight not armed. Use: wpai overnight arm -ParentTaskIds <id>' }

    try {
        $exp = [DateTime]::Parse([string]$plan.expires_at).ToUniversalTime()
        if ([DateTime]::UtcNow -gt $exp) {
            Clear-WpaiOvernightArm -Reason 'expired' | Out-Null
            throw 'Overnight arm expired'
        }
    } catch {
        if ($_.Exception.Message -match 'expired|not armed') { throw }
    }

    $ids = @($plan.parent_task_ids)
    if ($ids.Count -eq 0) { throw 'No parent_task_ids on overnight plan' }
    $maxRounds = [int]$plan.max_rounds
    if ($maxRounds -lt 1) { $maxRounds = 1 }

    $cfg = Get-WpaiConfig
    $cli = [string]$cfg.janus_cli
    $janusRoot = [string]$cfg.janus_root
    $results = @()
    $lockPath = Join-Path (Get-WpaiConfigValue -Name 'wpai_dir' -Default 'C:\WPAI\Workspace\.wpai') 'overnight.lock'
    if (Test-Path -LiteralPath $lockPath) {
        $age = (Get-Date) - (Get-Item -LiteralPath $lockPath).LastWriteTime
        if ($age.TotalHours -lt 6) { throw "Overnight already running (lock: $lockPath)" }
    }
    Set-Content -LiteralPath $lockPath -Value $PID -Encoding utf8

    try {
        foreach ($parentId in $ids) {
            for ($r = 1; $r -le $maxRounds; $r++) {
                $bb = Get-WpaiBlackboard
                if (Test-WpaiKillActive -Blackboard $bb -Kind 'loops') {
                    $results += [pscustomobject]@{ parent = $parentId; round = $r; status = 'aborted_kill' }
                    break
                }
                $cost = Get-WpaiCostEstimate -Rounds 1 -ExecutorInvocations 1
                $allow = Test-WpaiBudgetAllows -Blackboard $bb -AdditionalUsd $cost -AdditionalInvocations 1
                if (-not $allow.ok) {
                    Invoke-WpaiBlackboardRmw -Mutator {
                        param($b)
                        Add-WpaiEvent -Blackboard $b -Kind 'overnight' -StepKey 'janus.loop.aborted_budget' -Actor 'bridge' -Refs @{ reason = $allow.reason }
                    } | Out-Null
                    $results += [pscustomobject]@{ parent = $parentId; round = $r; status = 'aborted_budget'; reason = $allow.reason }
                    break
                }

                if ($DryRun) {
                    $results += [pscustomobject]@{ parent = $parentId; round = $r; status = 'dry_run'; cost = $cost }
                    # still charge estimate for dry accounting visibility? no
                    continue
                }

                # pre-charge conservative estimate
                Invoke-WpaiBlackboardRmw -Mutator {
                    param($b)
                    $b['budgets']['api_usd_spent_est_day'] = [double]$b['budgets']['api_usd_spent_est_day'] + $cost
                    $b['budgets']['api_usd_spent_est_month'] = [double]$b['budgets']['api_usd_spent_est_month'] + $cost
                    $b['budgets']['executor_invocations_day'] = [int]$b['budgets']['executor_invocations_day'] + 1
                } | Out-Null

                $parts = $cli -split '\s+', 2
                $exe = $parts[0]
                $bin = if ($parts.Count -gt 1) { $parts[1] } else { '' }
                $args = @()
                if ($bin) { $args += $bin }
                # Prefer in-process Janus budget gate (PR-09); still charge + re-check each external invocation
                $args += @('loop', 'run', '-t', $parentId, '--max-rounds', '1', '--wpai-budget-gate')
                $argStr = ($args | ForEach-Object { if ($_ -match '\s') { '"{0}"' -f $_ } else { $_ } }) -join ' '

                Write-WpaiLog -Name 'overnight' -Message ("START parent={0} round={1}/{2} cmd={3} {4}" -f $parentId, $r, $maxRounds, $exe, $argStr)

                $psi = New-Object System.Diagnostics.ProcessStartInfo
                $psi.FileName = $exe
                $psi.Arguments = $argStr
                $psi.WorkingDirectory = $janusRoot
                $psi.RedirectStandardOutput = $true
                $psi.RedirectStandardError = $true
                $psi.UseShellExecute = $false
                $psi.CreateNoWindow = $true
                try {
                    $p = [System.Diagnostics.Process]::Start($psi)
                    $stdout = $p.StandardOutput.ReadToEnd()
                    $stderr = $p.StandardError.ReadToEnd()
                    $p.WaitForExit()
                    $code = $p.ExitCode
                } catch {
                    $code = -1
                    $stdout = ''
                    $stderr = $_.Exception.Message
                }

                Write-WpaiLog -Name 'overnight' -Message ("END parent={0} round={1} exit={2}" -f $parentId, $r, $code)
                $results += [pscustomobject]@{
                    parent = $parentId
                    round  = $r
                    status = $(if ($code -eq 0) { 'ok' } else { 'error' })
                    exit   = $code
                    cost   = $cost
                }

                # optional: stop early if tasks accepted — best-effort parse
                if ($code -ne 0) { break }
            }
        }
    } finally {
        Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue
        Clear-WpaiOvernightArm -Reason 'run_complete' | Out-Null
        Invoke-WpaiBlackboardRmw -Mutator {
            param($b)
            if ($b['overnight'] -is [System.Collections.IDictionary]) {
                $b['overnight']['last_run'] = Get-WpaiUtcNow
                $b['overnight']['armed'] = $false
            }
            Add-WpaiEvent -Blackboard $b -Kind 'overnight' -StepKey 'janus.loop.complete' -Actor 'bridge' -Refs @{}
        } | Out-Null
        try { Sync-WpaiJanusProjection | Out-Null } catch { }
    }

    return [pscustomobject]@{ results = $results; dry_run = [bool]$DryRun }
}
