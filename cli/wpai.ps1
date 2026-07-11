<#
.SYNOPSIS
  WPAI studio control plane CLI — BLACKBOARD RMW, music gate, bridge, overnight.

.DESCRIPTION
  On-demand only (no daemon). Single logical writer for BLACKBOARD.json.
  Binding rule: no second task store; no unsupervised public publish.

.EXAMPLE
  pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 status
  pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 music check -EmitTicket
  pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 kill set loops true
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Command = 'help',

    [Parameter(Position = 1)]
    [string]$SubCommand = '',

    [switch]$EmitTicket,
    [switch]$DryRun,
    [switch]$Submit,
    [switch]$Force,
    [string]$Release,
    [string]$Job,
    [string]$ParentTaskIds,
    [int]$MaxRounds = 0,
    [double]$Budget = 0,
    [string]$Reason,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Rest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'lib\WpaiCore.ps1')
. (Join-Path $here 'lib\WpaiMusic.ps1')
. (Join-Path $here 'lib\WpaiBridge.ps1')
. (Join-Path $here 'lib\WpaiOvernight.ps1')

function Parse-WpaiRest {
    param([string[]]$Args)
    $map = @{}
    $i = 0
    $positional = @()
    while ($i -lt $Args.Count) {
        $a = $Args[$i]
        if ($a -match '^-(.+)$') {
            $key = $Matches[1]
            $next = if ($i + 1 -lt $Args.Count) { $Args[$i + 1] } else { $null }
            if ($null -ne $next -and $next -notmatch '^-') {
                $map[$key] = $next
                $i += 2
            } else {
                $map[$key] = $true
                $i += 1
            }
        } else {
            $positional += $a
            $i += 1
        }
    }
    return [pscustomobject]@{ Map = $map; Positional = $positional }
}

function Show-WpaiHelp {
    @"
WPAI control plane (on-demand)

  INSTALL
    wpai install [--force]

  STATUS / BOARD
    wpai status
    wpai board
    wpai board set-goal "text"
    wpai kill set <global|loops|research|publishes> <true|false>
    wpai kill status
    wpai budget status
    wpai budget set-day <usd>
    wpai budget set-month <usd>

  APPROVALS (ticket files = SoT)
    wpai approve list [pending|approved|rejected]
    wpai approve show <id>
    wpai approve decide <id> approved|rejected [-Reason "..."]

  MUSIC (package-ready; never auto-upload)
    wpai music check [-Release "Weaponized Mind"] [-EmitTicket]
    wpai music event-manual   # log manual_step for 3x promotion

  BRIDGE
    wpai bridge sync
    wpai bridge plan -Job <path-to-janus_job.json> [-Submit] [-DryRun]

  OVERNIGHT
    wpai overnight arm -ParentTaskIds id1[,id2] [-MaxRounds 10]
    wpai overnight disarm
    wpai overnight status
    wpai overnight start [-DryRun]

  DIVISION (Director checklist)
    wpai division activate ai_research -Budget 20
    wpai division status

  EVENTS / PROMOTION
    wpai events list
    wpai promote check

  ASSETS (Omni32 via Janus — no auto-deploy)
    wpai assets queue | stats
    wpai assets run <modId>

  Paths: C:\WPAI\Workspace\.wpai\
  Protocol: C:\WPAI\Workspace\.hellforge\PROTOCOL.md
"@
}

$cmd = $Command.ToLowerInvariant()
$sub = $SubCommand.ToLowerInvariant()
# Coerce Rest to string[] (named -Rest "a","b" or single string both work under StrictMode)
if ($null -eq $Rest) { $Rest = @() }
elseif ($Rest -is [string]) { $Rest = @($Rest) }
else { $Rest = @($Rest) }
$parsed = Parse-WpaiRest -Args $Rest
$map = $parsed.Map
$pos = @($parsed.Positional)
# Positional CLI form: wpai.ps1 <cmd> <sub> <args...>  — also accept bare words after sub as $pos

switch ($cmd) {
    'help' { Show-WpaiHelp; break }
    'install' {
        $force = [bool]$Force -or $map.ContainsKey('force') -or $map.ContainsKey('Force')
        $r = Ensure-WpaiRuntime -ForceTemplates:$force
        # copy PROTOCOL extension snippet
        $protoSrc = Join-Path $here 'templates\PROTOCOL-WPAI-EXTENSION.md'
        $hfProto = 'C:\WPAI\Workspace\.hellforge\PROTOCOL.md'
        if (Test-Path -LiteralPath $protoSrc) {
            $extPath = Join-Path $r.WpaiDir 'PROTOCOL-WPAI-EXTENSION.md'
            Copy-Item -LiteralPath $protoSrc -Destination $extPath -Force
        }
        Write-Host "WPAI runtime ready:" -ForegroundColor Green
        Write-Host "  $($r.WpaiDir)"
        Write-Host "  config:     $($r.ConfigPath)"
        Write-Host "  blackboard: $($r.Blackboard)"
        Write-Host "  approvals:  $($r.Approvals)"
        break
    }
    'status' {
        Ensure-WpaiRuntime | Out-Null
        $bb = Get-WpaiBlackboard
        $cfg = Get-WpaiConfig
        $pending = @(Get-WpaiApprovalTickets -Status 'pending')
        Write-Output "=== WPAI STATUS ==="
        Write-Output ("goal:     {0}" -f $bb.director_goal)
        Write-Output ("updated:  {0}  gen={1}" -f $bb.updated_at, $bb.generation)
        Write-Output ("kill:     global={0} loops={1} research={2} publishes={3}" -f `
                $bb.kill_switch.global, $bb.kill_switch.loops, $bb.kill_switch.research, $bb.kill_switch.publishes)
        Write-Output ("budget:   day {0}/{1} USD  month {2}/{3} USD  inv {4}/{5}" -f `
                $bb.budgets.api_usd_spent_est_day, $bb.budgets.api_usd_cap_day, `
                $bb.budgets.api_usd_spent_est_month, $bb.budgets.api_usd_cap_month, `
                $bb.budgets.executor_invocations_day, $bb.budgets.max_executor_invocations_day)
        Write-Output ("overnight armed={0} parents=[{1}] max_rounds={2}" -f `
                $bb.overnight.armed, (($bb.overnight.parent_task_ids) -join ','), $bb.overnight.max_rounds)
        Write-Output ("janus:    open={0} failed={1}" -f $bb.janus.open_tasks, $bb.janus.failed_tasks)
        Write-Output ("music:    next={0} checklist_pass={1}" -f $bb.pipelines.music_release.next, $bb.pipelines.music_release.checklist_pass)
        Write-Output ("approvals pending: {0}" -f $pending.Count)
        foreach ($t in $pending | Select-Object -First 10) {
            Write-Output ("  - {0} [{1}] {2}" -f $t.id, $t.kind, $t.summary)
        }
        Write-Output ("ai_research: state={0} revenue_covers={1} budget={2}" -f `
                $bb.divisions.ai_research.state, $bb.divisions.ai_research.revenue_covers_compute, `
                $bb.divisions.ai_research.compute_budget_usd_month)
        Write-Output ("config music_root={0}" -f $cfg.music_root)
        break
    }
    'board' {
        if ($sub -eq 'set-goal' -or $map.ContainsKey('goal') -or $map.ContainsKey('Goal')) {
            $goal = $null
            if ($map.ContainsKey('goal')) { $goal = [string]$map['goal'] }
            elseif ($map.ContainsKey('Goal')) { $goal = [string]$map['Goal'] }
            elseif ($pos.Count -gt 0) { $goal = ($pos -join ' ').Trim() }
            elseif ($Rest.Count -gt 0) { $goal = ($Rest -join ' ').Trim() }
            if (-not $goal) { throw 'goal text required' }
            Invoke-WpaiBlackboardRmw -Mutator {
                param($bb)
                $bb['director_goal'] = $goal
            } | Out-Null
            Write-Host "Goal set: $goal" -ForegroundColor Green
        } else {
            Get-WpaiBlackboard | ConvertTo-Json -Depth 12
        }
        break
    }
    'kill' {
        if ($sub -eq 'status' -or -not $sub) {
            $bb = Get-WpaiBlackboard
            $bb.kill_switch | ConvertTo-Json
        } elseif ($sub -eq 'set') {
            $which = if ($pos.Count -ge 1) { $pos[0] } elseif ($map.ContainsKey('Which')) { $map['Which'] } else { throw 'kill set <name> <true|false>' }
            $valRaw = if ($pos.Count -ge 2) { $pos[1] } elseif ($map.ContainsKey('Value')) { $map['Value'] } else { throw 'value true|false required' }
            $val = [System.Convert]::ToBoolean($valRaw)
            $which = $which.ToLowerInvariant()
            if ($which -notin @('global', 'loops', 'research', 'publishes')) { throw "unknown kill key: $which" }
            Invoke-WpaiBlackboardRmw -Mutator {
                param($bb)
                $bb['kill_switch'][$which] = $val
                Add-WpaiEvent -Blackboard $bb -Kind 'kill' -StepKey ("kill.{0}.{1}" -f $which, $val) -Actor 'director'
            } | Out-Null
            Write-Host ("kill_switch.{0} = {1}" -f $which, $val) -ForegroundColor Yellow
        } else { throw "unknown kill sub: $sub" }
        break
    }
    'budget' {
        if ($sub -eq 'status' -or -not $sub) {
            (Get-WpaiBlackboard).budgets | ConvertTo-Json
        } elseif ($sub -eq 'set-day') {
            $v = if ($pos.Count -gt 0) { [double]$pos[0] } elseif ($map.ContainsKey('Value')) { [double]$map['Value'] } else { throw 'value required' }
            Invoke-WpaiBlackboardRmw -Mutator { param($bb) $bb['budgets']['api_usd_cap_day'] = $v } | Out-Null
            Write-Host "day cap = $v"
        } elseif ($sub -eq 'set-month') {
            $v = if ($pos.Count -gt 0) { [double]$pos[0] } elseif ($map.ContainsKey('Value')) { [double]$map['Value'] } else { throw 'value required' }
            Invoke-WpaiBlackboardRmw -Mutator { param($bb) $bb['budgets']['api_usd_cap_month'] = $v } | Out-Null
            Write-Host "month cap = $v"
        } else { throw "unknown budget sub: $sub" }
        break
    }
    'approve' {
        if ($sub -eq 'list') {
            $st = if ($pos.Count -gt 0) { $pos[0] } else { 'pending' }
            if ($st -eq 'all') { $st = '' }
            Get-WpaiApprovalTickets -Status $st | Format-Table id, kind, status, summary -AutoSize
        } elseif ($sub -eq 'show') {
            if ($pos.Count -lt 1) { throw 'approve show <id>' }
            $id = $pos[0]
            $t = Get-WpaiApprovalTickets | Where-Object { $_.id -eq $id -or $_.id -like "*$id*" } | Select-Object -First 1
            if (-not $t) { throw "not found: $id" }
            Get-Content -LiteralPath $t.path -Raw
        } elseif ($sub -eq 'decide') {
            # Prefer positional words; fall back to raw Rest (named -Rest binding can be empty after switches)
            $words = @()
            if ($pos.Count -gt 0) { $words = @($pos) }
            elseif ($Rest.Count -gt 0) {
                foreach ($r in $Rest) {
                    if ($null -eq $r) { continue }
                    if ([string]$r -match '^-') { continue }
                    $words += [string]$r
                }
            }
            if ($words.Count -lt 2) {
                throw "decide <id> approved|rejected (got $($words.Count) args: $($words -join ', '))"
            }
            $id = $words[0]
            $dec = $words[1]
            if ($dec -notin @('approved', 'rejected')) { throw 'decide <id> approved|rejected' }
            $reason = if ($Reason) { $Reason } elseif ($map.ContainsKey('Reason')) { [string]$map['Reason'] } else { '' }
            $t = Set-WpaiApprovalDecision -Id $id -Decision $dec -DenyReason $reason
            Write-Host ("{0} -> {1}" -f $t.id, $t.status) -ForegroundColor Green
        } else { throw "unknown approve sub: $sub" }
        break
    }
    'music' {
        if ($sub -eq 'check') {
            $rel = $null
            if ($Release) { $rel = $Release }
            elseif ($map.ContainsKey('Release')) { $rel = [string]$map['Release'] }
            elseif ($pos.Count -gt 0) { $rel = [string]$pos[0] }
            $emit = [bool]$EmitTicket
            if ($map.ContainsKey('EmitTicket') -or $map.ContainsKey('emitTicket')) { $emit = $true }
            if ($Rest) {
                foreach ($ra in @($Rest)) {
                    if ([string]$ra -match 'EmitTicket') { $emit = $true }
                }
            }
            $r = Test-WpaiMusicPackage -ReleaseName $rel -EmitTicket:$emit
            Write-Output ("PASS={0}  release={1}" -f $r.pass, $r.release_name)
            $r.checks | Format-Table id, ok, detail -AutoSize | Out-String | Write-Output
            Write-Output ("report: {0}" -f $r.report_path)
            if ($r.ticket_path) { Write-Output ("ticket: {0}" -f $r.ticket_path) }
            if (-not $r.pass) { exit 1 }
        } elseif ($sub -eq 'event-manual') {
            Invoke-WpaiBlackboardRmw -Mutator {
                param($bb)
                Add-WpaiEvent -Blackboard $bb -Kind 'manual_step' -StepKey 'music.package_checklist.manual' -Division 'music' -Actor 'director'
            } | Out-Null
            Write-Host 'Logged music.package_checklist.manual'
        } else { throw "music sub required: check | event-manual" }
        break
    }
    'bridge' {
        if ($sub -eq 'sync') {
            $r = Sync-WpaiJanusProjection
            $r | Format-List
        } elseif ($sub -eq 'plan') {
            $jobPath = $null
            if ($Job) { $jobPath = $Job }
            elseif ($map.ContainsKey('Job')) { $jobPath = [string]$map['Job'] }
            elseif ($pos.Count -gt 0) { $jobPath = [string]$pos[0] }
            if (-not $jobPath) { throw '-Job path required' }
            $submit = [bool]$Submit -or $map.ContainsKey('Submit')
            $dry = [bool]$DryRun -or $map.ContainsKey('DryRun')
            $r = Invoke-WpaiJanusJobPlan -JobPath $jobPath -Submit:$submit -DryRun:$dry
            $r | Format-List
            if ($r.plan_path) { Write-Host "plan: $($r.plan_path)" -ForegroundColor Cyan }
            if ($r.submitted -eq $false -and $submit) { exit 1 }
        } else { throw 'bridge sub: sync | plan' }
        break
    }
    'overnight' {
        if ($sub -eq 'arm') {
            $idsRaw = $null
            if ($ParentTaskIds) { $idsRaw = $ParentTaskIds }
            elseif ($map.ContainsKey('ParentTaskIds')) { $idsRaw = [string]$map['ParentTaskIds'] }
            elseif ($pos.Count -gt 0) { $idsRaw = [string]$pos[0] }
            if (-not $idsRaw) { throw '-ParentTaskIds required' }
            $ids = @($idsRaw -split '[, ]+' | Where-Object { $_ })
            $mr = 10
            if ($MaxRounds -gt 0) { $mr = $MaxRounds }
            elseif ($map.ContainsKey('MaxRounds')) { $mr = [int]$map['MaxRounds'] }
            $p = Set-WpaiOvernightArm -ParentTaskIds $ids -MaxRounds $mr
            $p | ConvertTo-Json -Depth 5
        } elseif ($sub -eq 'disarm') {
            Clear-WpaiOvernightArm | ConvertTo-Json
        } elseif ($sub -eq 'status') {
            Read-WpaiOvernightPlan | ConvertTo-Json -Depth 5
        } elseif ($sub -eq 'start') {
            $dry = [bool]$DryRun -or $map.ContainsKey('DryRun')
            $r = Start-WpaiOvernight -DryRun:$dry
            $r.results | Format-Table -AutoSize
        } else { throw 'overnight sub: arm | disarm | status | start' }
        break
    }
    'division' {
        if ($sub -eq 'status') {
            (Get-WpaiBlackboard).divisions | ConvertTo-Json -Depth 6
        } elseif ($sub -eq 'activate') {
            $name = if ($pos.Count -gt 0) { $pos[0] } else { 'ai_research' }
            if ($name -ne 'ai_research') { throw 'Only ai_research activation implemented in Phase 0-3' }
            $budgetVal = $null
            if ($Budget -gt 0) { $budgetVal = $Budget }
            elseif ($map.ContainsKey('Budget')) { $budgetVal = [double]$map['Budget'] }
            elseif ($pos.Count -gt 1) { $budgetVal = [double]$pos[1] }
            if ($null -eq $budgetVal) { throw '-Budget required (>0)' }
            if ($budgetVal -le 0) { throw 'Budget must be > 0' }
            $budget = $budgetVal
            Invoke-WpaiBlackboardRmw -Mutator {
                param($bb)
                $ar = $bb['divisions']['ai_research']
                $ar['revenue_covers_compute'] = $true
                $ar['compute_budget_usd_month'] = $budget
                $ar['state'] = 'active'
                $ar['activated_by'] = 'director'
                $ar['activated_at'] = Get-WpaiUtcNow
            } | Out-Null
            Write-Host "ai_research activated with monthly compute budget $budget" -ForegroundColor Green
        } else { throw 'division sub: status | activate' }
        break
    }
    'events' {
        $bb = Get-WpaiBlackboard
        $n = if ($map['Count']) { [int]$map['Count'] } else { 20 }
        @($bb.events) | Select-Object -Last $n | ConvertTo-Json -Depth 6
        break
    }
    'promote' {
        if ($sub -eq 'check') {
            Get-WpaiPromotionCandidates | Format-Table -AutoSize
        } else { Get-WpaiPromotionCandidates | Format-Table -AutoSize }
        break
    }
    'assets' {
        # Budgeted Omni32 surface — never deploys without pack_deploy ticket
        if (Test-WpaiKillActive -Kind 'loops') { throw 'kill switch blocks assets' }
        $cfg = Get-WpaiConfig
        $cli = [string]$cfg.janus_cli
        $root = [string]$cfg.janus_root
        $parts = $cli -split '\s+', 2
        $exe = $parts[0]
        $bin = if ($parts.Count -gt 1) { $parts[1] } else { '' }
        $action = if ($sub) { $sub } else { 'queue' }
        $args = @()
        if ($bin) { $args += $bin }
        if ($action -eq 'queue' -or $action -eq 'stats') {
            $args += @('assets', $action)
        } elseif ($action -eq 'run') {
            $mod = if ($pos.Count -gt 0) { $pos[0] } else { throw 'assets run <modId>' }
            # charge cost model for one batch
            $cost = Get-WpaiCostEstimate -Rounds 1 -ExecutorInvocations 1
            $bb = Get-WpaiBlackboard
            $allow = Test-WpaiBudgetAllows -Blackboard $bb -AdditionalUsd $cost -AdditionalInvocations 1
            if (-not $allow.ok) { throw $allow.reason }
            Invoke-WpaiBlackboardRmw -Mutator {
                param($b)
                $b['budgets']['api_usd_spent_est_day'] = [double]$b['budgets']['api_usd_spent_est_day'] + $cost
                $b['budgets']['api_usd_spent_est_month'] = [double]$b['budgets']['api_usd_spent_est_month'] + $cost
                $b['budgets']['executor_invocations_day'] = [int]$b['budgets']['executor_invocations_day'] + 1
                Add-WpaiEvent -Blackboard $b -Kind 'pipeline' -StepKey 'omni32.batch' -Division 'graphics' -Actor 'bridge'
            } | Out-Null
            $args += @('assets', 'run', $mod)
        } else {
            throw 'assets sub: queue | stats | run <modId>  (deploy requires separate HITL pack_deploy ticket — not auto)'
        }
        $argStr = ($args | ForEach-Object { if ($_ -match '\s') { '"{0}"' -f $_ } else { $_ } }) -join ' '
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $exe
        $psi.Arguments = $argStr
        $psi.WorkingDirectory = $root
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        try {
            $p = [System.Diagnostics.Process]::Start($psi)
            Write-Output $p.StandardOutput.ReadToEnd()
            $err = $p.StandardError.ReadToEnd()
            $p.WaitForExit()
            if ($err) { Write-Host $err -ForegroundColor DarkYellow }
            if ($p.ExitCode -ne 0) { exit $p.ExitCode }
        } catch {
            Write-Host "Janus assets CLI unavailable: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "assets_root=$((Get-WpaiConfigValue -Name 'assets_root'))"
        }
        break
    }
    default {
        Show-WpaiHelp
        if ($cmd -ne 'help') { Write-Error "Unknown command: $cmd"; exit 2 }
    }
}
