# BLACKBOARD reliability — guess-then-falsify integrity (gen3 #1 path-8e633381189e)
# blackboard-not-chat: verification is a ledger check, not multi-agent debate.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-WpaiBlackboardRequiredKeys {
    return @(
        'schema_version', 'generation', 'updated_at', 'director_goal',
        'kill_switch', 'budgets', 'overnight', 'divisions', 'janus',
        'pipelines', 'approvals_pending', 'events'
    )
}

function Get-WpaiKillSwitchKeys {
    return @('global', 'loops', 'research', 'publishes')
}

function Get-WpaiBudgetRequiredKeys {
    return @(
        'period_day', 'period_month',
        'api_usd_cap_day', 'api_usd_cap_month',
        'api_usd_spent_est_day', 'api_usd_spent_est_month',
        'max_overnight_rounds', 'max_executor_invocations_day',
        'executor_invocations_day', 'max_parallel_workloads', 'cost_model_version'
    )
}

function Test-WpaiBlackboardShape {
    param($Blackboard)
    $issues = [System.Collections.Generic.List[string]]::new()
    if ($null -eq $Blackboard) {
        $issues.Add('blackboard is null')
        return [pscustomobject]@{ ok = $false; issues = @($issues) }
    }
    foreach ($k in Get-WpaiBlackboardRequiredKeys) {
        $p = $Blackboard.PSObject.Properties[$k]
        if ($null -eq $p) { $issues.Add("missing top-level key: $k") }
    }
    $gen = 0
    try { $gen = [int]$Blackboard.generation } catch { $issues.Add('generation not int') }
    if ($gen -lt 1) { $issues.Add("generation < 1: $gen") }

    $ks = $Blackboard.kill_switch
    if ($null -eq $ks) {
        $issues.Add('kill_switch missing')
    } else {
        foreach ($k in Get-WpaiKillSwitchKeys) {
            $p = $ks.PSObject.Properties[$k]
            if ($null -eq $p) { $issues.Add("kill_switch.$k missing") }
            else {
                $v = $p.Value
                if ($v -isnot [bool] -and "$v" -notin @('True', 'False', 'true', 'false')) {
                    # allow bool-ish
                    try { [void][bool]$v } catch { $issues.Add("kill_switch.$k not boolean-ish") }
                }
            }
        }
    }

    $b = $Blackboard.budgets
    if ($null -eq $b) {
        $issues.Add('budgets missing')
    } else {
        foreach ($k in Get-WpaiBudgetRequiredKeys) {
            $p = $b.PSObject.Properties[$k]
            if ($null -eq $p) { $issues.Add("budgets.$k missing") }
        }
        try {
            if ([double]$b.api_usd_spent_est_day -gt [double]$b.api_usd_cap_day + 0.001) {
                $issues.Add('spent_day exceeds cap_day (estimate overrun — not fatal but flagged)')
            }
        } catch { }
        try {
            if ([double]$b.api_usd_spent_est_day -lt 0 -or [double]$b.api_usd_spent_est_month -lt 0) {
                $issues.Add('negative spend estimate')
            }
        } catch { $issues.Add('spend fields not numeric') }
    }

    $ov = $Blackboard.overnight
    if ($null -eq $ov) {
        $issues.Add('overnight missing')
    } else {
        foreach ($k in @('armed', 'parent_task_ids', 'max_rounds')) {
            if ($null -eq $ov.PSObject.Properties[$k]) { $issues.Add("overnight.$k missing") }
        }
        if ($ov.armed -eq $true) {
            $pids = @($ov.parent_task_ids)
            if ($pids.Count -lt 1) { $issues.Add('overnight armed but parent_task_ids empty') }
        }
    }

    $evProp = $Blackboard.PSObject.Properties['events']
    if ($null -eq $evProp) {
        $issues.Add('events missing')
    } elseif ($null -eq $evProp.Value) {
        $issues.Add('events null')
    } elseif ($evProp.Value -is [System.Collections.IEnumerable] -and -not ($evProp.Value -is [string])) {
        $n = @($evProp.Value).Count
        if ($n -gt 200) { $issues.Add("events ring overflow: $n > 200") }
    }

    $fatal = @($issues | Where-Object { $_ -notmatch 'estimate overrun' })
    return [pscustomobject]@{
        ok     = ($fatal.Count -eq 0)
        issues = @($issues)
        generation = $gen
    }
}

function Repair-WpaiBlackboardSchema {
    <#
    .SYNOPSIS
      Fill missing schema keys without clearing kill/spend/goal. Never resets generation downward.
    #>
    $defaults = Get-WpaiDefaultBlackboard
    Invoke-WpaiBlackboardRmw -Mutator {
        param($bb)
        foreach ($k in $defaults.Keys) {
            if (-not $bb.Contains($k) -or $null -eq $bb[$k]) {
                if ($k -eq 'generation') { continue }
                if ($k -eq 'events') { $bb['events'] = @(); continue }
                $bb[$k] = $defaults[$k]
            }
        }
        # kill_switch keys
        if ($bb['kill_switch'] -isnot [System.Collections.IDictionary]) {
            $bb['kill_switch'] = $defaults['kill_switch']
        } else {
            foreach ($kk in @('global', 'loops', 'research', 'publishes')) {
                if (-not $bb['kill_switch'].Contains($kk)) { $bb['kill_switch'][$kk] = $false }
            }
        }
        if ($bb['budgets'] -isnot [System.Collections.IDictionary]) {
            $bb['budgets'] = $defaults['budgets']
        } else {
            $db = $defaults['budgets']
            foreach ($bk in $db.Keys) {
                if (-not $bb['budgets'].Contains($bk)) { $bb['budgets'][$bk] = $db[$bk] }
            }
        }
        if ($bb['overnight'] -isnot [System.Collections.IDictionary]) {
            $bb['overnight'] = $defaults['overnight']
        }
        if ($null -eq $bb['events']) { $bb['events'] = @() }
        if ($null -eq $bb['approvals_pending']) { $bb['approvals_pending'] = @() }
        Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'blackboard.repair_schema' -Actor 'bridge'
    } | Out-Null
}

function Invoke-WpaiBlackboardFalsify {
    <#
    .SYNOPSIS
      Guess-then-falsify stress: concurrent RMW must not drop kill flags or shrink generation.
    .OUTPUTS
      Result with ok, trials, issues, static_score
    #>
    param(
        [int]$Workers = 8,
        [int]$PerWorker = 4
    )
    Ensure-WpaiRuntime | Out-Null
    $cliLib = Split-Path $PSCommandPath -Parent
    $shape0 = Test-WpaiBlackboardShape -Blackboard (Get-WpaiBlackboard)
    if (-not $shape0.ok) {
        Repair-WpaiBlackboardSchema
        $shape0 = Test-WpaiBlackboardShape -Blackboard (Get-WpaiBlackboard)
    }

    $genBefore = [int](Get-WpaiBlackboard).generation
    # Plant a distinctive kill fingerprint — must survive concurrent noise
    Invoke-WpaiBlackboardRmw -Mutator {
        param($bb)
        $bb['kill_switch']['research'] = $true
        $bb['director_goal'] = 'falsify-probe-goal-' + (Get-Random -Maximum 99999)
    } | Out-Null
    $goalPlanted = [string](Get-WpaiBlackboard).director_goal
    $genPlanted = [int](Get-WpaiBlackboard).generation

    $jobs = 1..$Workers | ForEach-Object {
        Start-Job -ScriptBlock {
            param($lib, $n)
            . (Join-Path $lib 'WpaiCore.ps1')
            for ($i = 0; $i -lt $n; $i++) {
                Invoke-WpaiBlackboardRmw -Mutator {
                    param($bb)
                    # Must NOT clear research kill — noise events only
                    Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'falsify.noise' -Actor 'bridge' -Refs @{
                        pid = $PID
                    }
                } | Out-Null
            }
        } -ArgumentList $cliLib, $PerWorker
    }
    $jobs | Wait-Job | Out-Null
    $jobs | Remove-Job -Force -ErrorAction SilentlyContinue

    $bb = Get-WpaiBlackboard
    $issues = [System.Collections.Generic.List[string]]::new()
    $genAfter = [int]$bb.generation
    $minExpected = $genPlanted + ($Workers * $PerWorker)
    # Allow some retry overhead but generation must strictly increase overall
    if ($genAfter -le $genPlanted) {
        $issues.Add("generation did not advance under concurrency: planted=$genPlanted after=$genAfter")
    }
    if ($genAfter -lt $genBefore) {
        $issues.Add("generation went backwards: $genBefore -> $genAfter")
    }
    $researchKill = $false
    try { $researchKill = [bool]$bb.kill_switch.research } catch { $issues.Add('kill_switch.research unreadable') }
    if (-not $researchKill) {
        $issues.Add('FALSIFIED: concurrent RMW cleared kill_switch.research (must never happen)')
    }
    # Goal may be overwritten by other processes; only check if still our prefix or any non-empty
    if ([string]::IsNullOrWhiteSpace([string]$bb.director_goal)) {
        $issues.Add('director_goal empty after stress')
    }

    $shape1 = Test-WpaiBlackboardShape -Blackboard $bb
    foreach ($i in $shape1.issues) { $issues.Add("shape: $i") }

    # Clear research kill (leave system safe) — but only via explicit mutator (human-style)
    Invoke-WpaiBlackboardRmw -Mutator {
        param($b)
        $b['kill_switch']['research'] = $false
        if ([string]$b['director_goal'] -like 'falsify-probe-goal-*') {
            $b['director_goal'] = 'Ship Weaponized Mind on DistroKid; budgeted overnight only when armed'
        }
        Add-WpaiEvent -Blackboard $b -Kind 'pipeline' -StepKey 'falsify.cleanup' -Actor 'bridge'
    } | Out-Null

    $checks = 4
    $passed = 0
    if ($genAfter -gt $genPlanted) { $passed++ }
    if ($researchKill) { $passed++ }
    if ($shape1.ok) { $passed++ }
    if ($genAfter -ge $genBefore) { $passed++ }
    $score = [math]::Round($passed / [double]$checks, 4)
    $ok = ($issues.Count -eq 0)

    $result = [pscustomobject]@{
        path_id       = 'path-8e633381189e'
        ok            = $ok
        static_score  = $score
        generation_before = $genBefore
        generation_planted = $genPlanted
        generation_after  = $genAfter
        workers       = $Workers
        per_worker    = $PerWorker
        kill_research_held = $researchKill
        issues        = @($issues)
        verdict       = $(if ($ok) { 'SUPPORTED' } else { 'FALSIFIED' })
        note          = 'blackboard-not-chat: integrity is a ledger probe, not agent debate'
    }
    return $result
}

function Invoke-WpaiBlackboardDoctor {
    param(
        [switch]$DoRepair,
        [switch]$DoFalsify,
        [int]$Workers = 6,
        [int]$PerWorker = 3
    )
    # Note: do not name params $Repair/$Falsify — PS is case-insensitive and
    # overwriting them with result objects breaks switch semantics.
    $bb = Get-WpaiBlackboard
    $shape = Test-WpaiBlackboardShape -Blackboard $bb
    $repaired = $false
    if ($DoRepair -and -not $shape.ok) {
        Repair-WpaiBlackboardSchema
        $repaired = $true
        $bb = Get-WpaiBlackboard
        $shape = Test-WpaiBlackboardShape -Blackboard $bb
    }
    $falsifyResult = $null
    if ($DoFalsify) {
        $falsifyResult = Invoke-WpaiBlackboardFalsify -Workers $Workers -PerWorker $PerWorker
    }

    # Re-read after optional falsify so report matches disk
    $bb2 = Get-WpaiBlackboard
    $shape2 = Test-WpaiBlackboardShape -Blackboard $bb2
    $spentDay = 0
    $capDay = 5
    try { $spentDay = [double]$bb2.budgets.api_usd_spent_est_day } catch { }
    try { $capDay = [double]$bb2.budgets.api_usd_cap_day } catch { }
    $armed = $false
    try { $armed = [bool]$bb2.overnight.armed } catch { }
    $falsifyOk = $true
    if ($null -ne $falsifyResult) {
        $falsifyOk = [bool]$falsifyResult.ok
    }
    $out = [ordered]@{
        schema_version  = '1.0.0'
        ts              = (Get-WpaiUtcNow)
        generation      = $(try { [int]$bb2.generation } catch { 0 })
        shape_ok        = [bool]$shape2.ok
        shape_issues    = @($shape2.issues)
        repaired        = $repaired
        falsify         = $falsifyResult
        kill_switch     = $bb2.kill_switch
        budget_day      = ('{0}/{1}' -f $spentDay, $capDay)
        overnight_armed = $armed
        ok              = ([bool]$shape2.ok -and $falsifyOk)
    }

    # blackboard-not-chat: one bus status telegram
    try {
        if (Get-Command Write-WpaiBusMessage -ErrorAction SilentlyContinue) {
            $msg = if ($out.ok) { "board verify OK gen=$($out.generation)" } else { "board verify FAIL gen=$($out.generation)" }
            Write-WpaiBusMessage -Text $msg -Type 'status' -From 'bridge' -To 'director' | Out-Null
        }
    } catch { }

    # append observe-style log
    try {
        $logDir = Join-Path (Get-WpaiConfigValue -Name 'wpai_dir' -Default 'C:\WPAI\Workspace\.wpai') 'logs'
        if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
        $line = ($out | ConvertTo-Json -Compress -Depth 8)
        Add-Content -LiteralPath (Join-Path $logDir 'board-verify.jsonl') -Value $line -Encoding utf8
    } catch { }

    return [pscustomobject]$out
}
