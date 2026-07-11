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
    [switch]$WhatIf,
    [switch]$Repair,
    [switch]$Falsify,
    [string]$Release,
    [string]$Job,
    [string]$ParentTaskIds,
    [int]$MaxRounds = 0,
    [double]$Budget = 0,
    [string]$Reason,
    [int]$OlderThanDays = 0,
    [int]$Count = 0,
    [int]$Top = 0,
    [int]$Probe = 0,
    [int]$Keep = 0,
    [int]$Inject = 0,
    [int]$Briefs = 0,
    [int]$Waves = 0,
    [int]$AutoLimit = 0,
    [int]$Limit = 0,
    [string]$PathId = '',
    [string]$Verdict = '',
    [string]$Note = '',
    [switch]$Quiet,
    [switch]$SkipTasks,
    [switch]$SkipLearn,
    [switch]$SkipMutate,
    [switch]$SkipTests,
    [switch]$SelfOnly,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Rest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here 'lib\WpaiCore.ps1')
. (Join-Path $here 'lib\WpaiBus.ps1')
. (Join-Path $here 'lib\WpaiMusic.ps1')
. (Join-Path $here 'lib\WpaiBridge.ps1')
. (Join-Path $here 'lib\WpaiOvernight.ps1')
. (Join-Path $here 'lib\WpaiResearch.ps1')
. (Join-Path $here 'lib\WpaiImproveSwarm.ps1')
. (Join-Path $here 'lib\WpaiBlackboardVerify.ps1')
if (Test-Path (Join-Path $here 'lib\WpaiBudgetLedger.ps1')) { . (Join-Path $here 'lib\WpaiBudgetLedger.ps1') }
if (Test-Path (Join-Path $here 'lib\WpaiObserve.ps1')) { . (Join-Path $here 'lib\WpaiObserve.ps1') }
. (Join-Path $here 'lib\WpaiBudgetLedger.ps1')
. (Join-Path $here 'lib\WpaiObserve.ps1')

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
    wpai board verify [-Repair] [-Falsify]   # gen3 #1 integrity (guess-then-falsify)
    wpai kill set <global|loops|research|publishes> <true|false>
    wpai kill status
    wpai budget status
    wpai budget ledger [-Tail N]          # day/month spent vs caps + double-entry log
    wpai budget charge [-Budget usd] [-DryRun]  # dry spend estimate (no paid API)
    wpai budget set-day <usd>
    wpai budget set-month <usd>

  APPROVALS (ticket files = SoT)
    wpai approve list [pending|approved|rejected]
    wpai approve show <id>
    wpai approve decide <id> approved|rejected [-Reason "..."]
    wpai approve pending-ids
    wpai approve purge-resolved [-OlderThanDays 7]

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

  RESEARCH (funding-gated; local only)
    wpai research request [-Budget 20]
    wpai research status
    wpai research run [-MetaGenerations 3] [-DryRun]

  BUS
    wpai bus archive [-Keep 500]

  IMPROVE SWARM (brute-force path search — hundreds of hypotheses)
    wpai improve seed [-Count 300] [-Force]
    wpai improve generation [-Top 40] [-Probe 12]
    wpai improve leaders
    wpai improve briefs [-Top 8]
    wpai improve mutate [-Keep 30] [-Inject 80]
    wpai improve record -PathId path-... -Verdict KILLED|SUPPORTED [-Note "..."]
    wpai improve learn                    # ingest kills/experiments → bans
    wpai improve run [-Top 40] [-Probe 12] [-Briefs 8]  # learn→mutate→gen
    wpai improve self-inject              # meta recipes → improve the swarm
    wpai improve auto [-Limit 12] [-SelfOnly]  # auto-experiments on survivors
    wpai improve unleash [-Waves 2] [-AutoLimit 12] [-Briefs 8]  # swarm eats itself
    wpai improve purge                    # trash rubber-stamps; keep breakthroughs
    wpai improve doctor                   # reliability gate
    wpai improve review                   # auto-review: IDEA vs PROPERTY vs SHIPPED + run unit tests
    wpai improve status | outcomes | bans | learning | elite
    (see improve-swarm/README.md — diverge → learn → probe → converge → unleash)

  OBSERVE (high-signal snapshot; append-only jsonl — not a poll loop)
    wpai observe snapshot [-SkipTasks] [-Quiet]
    (also: improve-swarm/experiments/run-observe.ps1)
    Prefer event-driven bus over high-frequency polling (min ~30s).

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
        } elseif ($sub -eq 'verify' -or $sub -eq 'doctor') {
            $doRepair = [bool]$Repair -or [bool]$Force -or $map.ContainsKey('Repair')
            $doFalsify = [bool]$Falsify -or $map.ContainsKey('Falsify')
            if ($sub -eq 'doctor') { $doRepair = $true; $doFalsify = $true }
            $r = Invoke-WpaiBlackboardDoctor -DoRepair:$doRepair -DoFalsify:$doFalsify
            $r | ConvertTo-Json -Depth 10
            if (-not $r.ok) { exit 1 }
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
            # Collect free words from pos and Rest (pwsh may bind "true" oddly)
            $words = [System.Collections.Generic.List[string]]::new()
            foreach ($w in @($pos)) { if ($null -ne $w -and [string]$w -ne '') { $words.Add([string]$w) } }
            foreach ($w in @($Rest)) {
                if ($null -eq $w) { continue }
                $s = [string]$w
                if ($s -match '^-') { continue }
                $words.Add($s)
            }
            if ($words.Count -lt 2 -and $map.ContainsKey('Which') -and $map.ContainsKey('Value')) {
                $words.Clear()
                $words.Add([string]$map['Which'])
                $words.Add([string]$map['Value'])
            }
            if ($words.Count -lt 2) { throw 'kill set <name> <true|false>' }
            $which = $words[0].ToLowerInvariant()
            $valRaw = $words[1]
            # Accept True/False/1/0/yes/no
            $val = $false
            if ($valRaw -match '^(true|1|yes|on)$') { $val = $true }
            elseif ($valRaw -match '^(false|0|no|off)$') { $val = $false }
            else {
                try { $val = [System.Convert]::ToBoolean($valRaw) } catch { throw "value true|false required, got: $valRaw" }
            }
            if ($which -notin @('global', 'loops', 'research', 'publishes')) { throw "unknown kill key: $which" }
            Invoke-WpaiBlackboardRmw -Mutator {
                param($bb)
                $bb['kill_switch'][$which] = $val
                Add-WpaiEvent -Blackboard $bb -Kind 'kill' -StepKey ("kill.{0}.{1}" -f $which, $val) -Actor 'director'
            } | Out-Null
            try {
                Write-WpaiBusMessage -Text ("kill $which=$val") -Type 'kill' -From 'director' -To 'all' | Out-Null
            } catch { }
            Write-Host ("kill_switch.{0} = {1}" -f $which, $val) -ForegroundColor Yellow
        } else { throw "unknown kill sub: $sub" }
        break
    }
    'budget' {
        if ($sub -eq 'status' -or -not $sub) {
            (Get-WpaiBlackboard).budgets | ConvertTo-Json
        } elseif ($sub -eq 'ledger') {
            $tail = 10
            if ($map.ContainsKey('Tail')) { $tail = [int]$map['Tail'] }
            elseif ($pos.Count -gt 0) { $tail = [int]$pos[0] }
            Show-WpaiBudgetLedger -Tail $tail | Out-Null
        } elseif ($sub -eq 'charge') {
            # Dry accounting charge (no paid APIs). Prefer -Budget; else cost-model default.
            $usd = 0.0
            if ($Budget -gt 0) { $usd = $Budget }
            elseif ($map.ContainsKey('Budget')) { $usd = [double]$map['Budget'] }
            elseif ($map.ContainsKey('Usd')) { $usd = [double]$map['Usd'] }
            elseif ($pos.Count -gt 0) { $usd = [double]$pos[0] }
            $memo = if ($Reason) { $Reason } elseif ($map.ContainsKey('Memo')) { [string]$map['Memo'] } else { 'cli budget charge' }
            $r = Add-WpaiBudgetCharge -Usd $usd -Memo $memo -DryRun:$DryRun
            Write-Host ("charge entry={0} usd={1} applied={2} dry={3}" -f $r.entry_id, $r.usd, $r.applied, $r.dry_run) -ForegroundColor Cyan
            if ($r.applied) {
                Write-Host ("  day_after={0} month_after={1}" -f $r.day_after, $r.month_after)
            }
            Write-Host ("  ledger={0}" -f $r.ledger_path)
        } elseif ($sub -eq 'set-day') {
            $v = if ($pos.Count -gt 0) { [double]$pos[0] } elseif ($map.ContainsKey('Value')) { [double]$map['Value'] } else { throw 'value required' }
            $old = 0.0
            try { $old = [double](Get-WpaiBlackboard).budgets.api_usd_cap_day } catch { $old = 0.0 }
            Invoke-WpaiBlackboardRmw -Mutator { param($bb) $bb['budgets']['api_usd_cap_day'] = $v } | Out-Null
            Write-WpaiBudgetCapChange -Period day -NewCap $v -OldCap $old | Out-Null
            Write-Host "day cap = $v"
        } elseif ($sub -eq 'set-month') {
            $v = if ($pos.Count -gt 0) { [double]$pos[0] } elseif ($map.ContainsKey('Value')) { [double]$map['Value'] } else { throw 'value required' }
            $old = 0.0
            try { $old = [double](Get-WpaiBlackboard).budgets.api_usd_cap_month } catch { $old = 0.0 }
            Invoke-WpaiBlackboardRmw -Mutator { param($bb) $bb['budgets']['api_usd_cap_month'] = $v } | Out-Null
            Write-WpaiBudgetCapChange -Period month -NewCap $v -OldCap $old | Out-Null
            Write-Host "month cap = $v"
        } else { throw "unknown budget sub: $sub (status|ledger|charge|set-day|set-month)" }
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
        } elseif ($sub -eq 'pending-ids') {
            $ids = @(Get-WpaiPendingApprovalIds)
            foreach ($id in $ids) { Write-Output $id }
        } elseif ($sub -eq 'purge-resolved') {
            $days = 7
            if ($OlderThanDays -gt 0) { $days = $OlderThanDays }
            elseif ($map.ContainsKey('OlderThanDays')) { $days = [int]$map['OlderThanDays'] }
            elseif ($pos.Count -gt 0 -and $pos[0] -match '^\d+$') { $days = [int]$pos[0] }
            $doWhatIf = [bool]$WhatIf -or $map.ContainsKey('WhatIf') -or $map.ContainsKey('whatif')
            foreach ($ra in @($Rest)) {
                if ([string]$ra -match '^(?i)-?WhatIf$') { $doWhatIf = $true }
            }
            $r = Remove-WpaiResolvedApprovals -OlderThanDays $days -WhatIf:$doWhatIf
            Write-Output ("purge-resolved: deleted={0} skipped={1} older_than_days={2}" -f `
                    $r.deleted_count, $r.skipped, $r.older_than_days)
            if ($r.deleted_count -gt 0) {
                $r.deleted | Format-Table id, status, action -AutoSize | Out-String | Write-Output
            }
        } else { throw "unknown approve sub: $sub (list|show|decide|pending-ids|purge-resolved)" }
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
    'research' {
        if ($sub -eq 'request') {
            $b = if ($Budget -gt 0) { $Budget } else { 20 }
            $c = Request-WpaiResearchEnable -BudgetUsdMonth $b
            Write-Host "Ticket: $($c.Path)" -ForegroundColor Green
            Write-Host "Director: wpai approve decide $($c.Ticket.id) approved"
            Write-Host "Then:     wpai division activate ai_research -Budget $b"
        } elseif ($sub -eq 'status') {
            Test-WpaiResearchAllowed | ConvertTo-Json
            (Get-WpaiBlackboard).divisions.ai_research | ConvertTo-Json
        } elseif ($sub -eq 'run') {
            $mg = if ($MaxRounds -gt 0) { $MaxRounds } else { 3 }
            if ($map.ContainsKey('MetaGenerations')) { $mg = [int]$map['MetaGenerations'] }
            $dry = [bool]$DryRun
            try {
                $r = Start-WpaiResearchRun -MetaGenerations $mg -DryRun:$dry
                $r | Format-List
            } catch {
                Write-Host ("research refused: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
                exit 1
            }
        } else { throw 'research sub: request | status | run' }
        break
    }
    'bus' {
        if ($sub -eq 'archive') {
            $keepN = if ($map.ContainsKey('Keep')) { [int]$map['Keep'] } else { 500 }
            Invoke-WpaiBusArchive -KeepLines $keepN | Format-List
        } else { throw 'bus sub: archive' }
        break
    }
    'observe' {
        # Read-only high-signal snapshot → logs/observe.jsonl (no BLACKBOARD write)
        if ($sub -eq 'snapshot' -or -not $sub) {
            $skipT = [bool]$SkipTasks -or $map.ContainsKey('SkipTasks') -or $map.ContainsKey('skipTasks')
            $quiet = [bool]$Quiet -or $map.ContainsKey('Quiet') -or $map.ContainsKey('quiet')
            $r = Write-WpaiObserveSnapshot -SkipTasks:$skipT -Quiet:$quiet
            if ($quiet) {
                # still return machine-usable one-liner path for scripts
                Write-Output $r.log_path
            }
        } else {
            throw 'observe sub: snapshot'
        }
        break
    }
    'improve' {
        if ($sub -eq 'seed') {
            $n = if ($Count -gt 0) { $Count } elseif ($map.ContainsKey('Count')) { [int]$map['Count'] } else { 300 }
            $r = Initialize-WpaiImproveCatalog -Count $n -Force:$Force
            Write-Host ("catalog: {0} paths @ {1} (regenerated={2} skipped_banned={3})" -f $r.count, $r.path, $r.regenerated, $r.skipped_banned) -ForegroundColor Green
        } elseif ($sub -eq 'generation' -or $sub -eq 'gen') {
            $topN = if ($Top -gt 0) { $Top } elseif ($map.ContainsKey('Top')) { [int]$map['Top'] } else { 40 }
            $probeN = if ($Probe -gt 0) { $Probe } elseif ($map.ContainsKey('Probe')) { [int]$map['Probe'] } else { 12 }
            $n = if ($Count -gt 0) { $Count } else { 300 }
            $r = Invoke-WpaiImproveGeneration -Top $topN -Probe $probeN -Count $n
            Write-Host ("generation {0}: catalog={1} survivors={2} top={3} banned_in_catalog={4}" -f $r.generation, $r.catalog_size, $r.survivors, $r.top_score, $r.banned_in_catalog) -ForegroundColor Green
            Write-Host ("top: {0}" -f $r.top_hypothesis)
            Write-Host ("leaders: {0}" -f $r.leaders_path)
            Write-Host ("artifact: {0}" -f $r.generation_path)
        } elseif ($sub -eq 'leaders') {
            Write-Output (Get-WpaiImproveLeaders)
        } elseif ($sub -eq 'briefs') {
            $topN = if ($Top -gt 0) { $Top } elseif ($map.ContainsKey('Top')) { [int]$map['Top'] } else { 8 }
            $r = Export-WpaiImproveBriefs -Top $topN
            Write-Host ("wrote {0} briefs for generation {1}" -f $r.count, $r.generation) -ForegroundColor Green
            $r.paths | ForEach-Object { Write-Host "  $_" }
        } elseif ($sub -eq 'mutate') {
            $k = if ($Keep -gt 0) { $Keep } elseif ($map.ContainsKey('Keep')) { [int]$map['Keep'] } else { 30 }
            $inj = if ($Inject -gt 0) { $Inject } elseif ($map.ContainsKey('Inject')) { [int]$map['Inject'] } else { 80 }
            $r = Invoke-WpaiImproveMutate -Keep $k -Inject $inj
            Write-Host ("mutated catalog: {0} paths (from gen {1}, kept={2}, skipped_banned={3})" -f $r.count, $r.from_generation, $r.kept, $r.skipped_banned) -ForegroundColor Green
            Write-Host 'Next: wpai improve generation'
        } elseif ($sub -eq 'record') {
            $pid = if ($PathId) { $PathId } elseif ($map.ContainsKey('PathId')) { [string]$map['PathId'] } elseif ($pos.Count -ge 1) { [string]$pos[0] } else { '' }
            $ver = if ($Verdict) { $Verdict } elseif ($map.ContainsKey('Verdict')) { [string]$map['Verdict'] } elseif ($pos.Count -ge 2) { [string]$pos[1] } else { '' }
            $nte = if ($Note) { $Note } elseif ($map.ContainsKey('Note')) { [string]$map['Note'] } else { '' }
            if (-not $pid -or -not $ver) { throw 'improve record requires -PathId and -Verdict KILLED|SUPPORTED|INCONCLUSIVE' }
            $r = Write-WpaiImproveOutcome -PathId $pid -Verdict $ver.ToUpperInvariant() -Source 'manual' -Note $nte
            if ($r.deduped) {
                Write-Host ("outcome already recorded: {0} {1}" -f $r.path_id, $r.verdict) -ForegroundColor Yellow
            } else {
                Write-Host ("recorded {0} → {1} ({2})" -f $r.path_id, $r.verdict, $r.path) -ForegroundColor Green
            }
            Write-Host 'Tip: wpai improve learn  # refresh bans from ledger'
        } elseif ($sub -eq 'learn') {
            $r = Invoke-WpaiImproveLearn
            Write-Host ("learn: outcomes={0} (+{1} new) bans={2} (+{3}) kills={4} supported={5}" -f `
                $r.outcomes_total, $r.ingested, $r.bans_total, $r.bans_added, $r.kills, $r.supported) -ForegroundColor Green
            Write-Host ("bans: {0}" -f $r.bans_path)
            Write-Host ("report: {0}" -f $r.learning_path)
        } elseif ($sub -eq 'run') {
            $topN = if ($Top -gt 0) { $Top } elseif ($map.ContainsKey('Top')) { [int]$map['Top'] } else { 40 }
            $probeN = if ($Probe -gt 0) { $Probe } elseif ($map.ContainsKey('Probe')) { [int]$map['Probe'] } else { 12 }
            $n = if ($Count -gt 0) { $Count } elseif ($map.ContainsKey('Count')) { [int]$map['Count'] } else { 300 }
            $k = if ($Keep -gt 0) { $Keep } elseif ($map.ContainsKey('Keep')) { [int]$map['Keep'] } else { 30 }
            $inj = if ($Inject -gt 0) { $Inject } elseif ($map.ContainsKey('Inject')) { [int]$map['Inject'] } else { 80 }
            $br = if ($Briefs -gt 0) { $Briefs } elseif ($map.ContainsKey('Briefs')) { [int]$map['Briefs'] } else { 0 }
            $r = Invoke-WpaiImproveRun -Count $n -Top $topN -Probe $probeN -Keep $k -Inject $inj -Briefs $br `
                -SkipLearn:$SkipLearn -SkipMutate:$SkipMutate -ForceSeed:$Force
            if ($r.learn) {
                Write-Host ("learn: outcomes={0} bans={1} (+{2})" -f $r.learn.outcomes_total, $r.learn.bans_total, $r.learn.bans_added) -ForegroundColor Cyan
            }
            if ($r.mutate) {
                Write-Host ("mutate: catalog={0} skipped_banned={1}" -f $r.mutate.count, $r.mutate.skipped_banned) -ForegroundColor Cyan
            }
            if ($r.seed) {
                Write-Host ("seed: catalog={0}" -f $r.seed.count) -ForegroundColor Cyan
            }
            $g = $r.generation
            Write-Host ("generation {0}: survivors={1} top={2} banned_in_catalog={3}" -f $g.generation, $g.survivors, $g.top_score, $g.banned_in_catalog) -ForegroundColor Green
            Write-Host ("top: {0}" -f $g.top_hypothesis)
            Write-Host ("leaders: {0}" -f $g.leaders_path)
            if ($r.briefs) {
                Write-Host ("briefs: {0}" -f $r.briefs.count) -ForegroundColor Green
            }
        } elseif ($sub -eq 'status') {
            $s = Get-WpaiImproveStatus
            Write-Host ("catalog_paths={0} generation_max={1} outcomes={2} bans={3} kills={4} experiments={5}" -f `
                $s.catalog_paths, $s.generation_max, $s.outcomes, $s.bans, $s.kill_files, $s.experiment_results)
            Write-Host ("runtime: {0}" -f $s.runtime_dir)
            Write-Host ("outcomes: {0}" -f $s.outcomes_path)
            Write-Host ("bans: {0}" -f $s.bans_path)
            Write-Host ("learning: {0}" -f $s.learning_path)
        } elseif ($sub -eq 'outcomes') {
            $rows = @(Read-WpaiImproveOutcomes)
            if ($rows.Count -eq 0) {
                Write-Host 'No outcomes yet. Record kills/experiments or run: wpai improve learn'
            } else {
                $rows | Select-Object -Last 40 | ForEach-Object {
                    Write-Output ("{0}  {1,-12}  {2,-12}  {3}  {4}" -f $_.ts, $_.verdict, $_.source, $_.path_id, $_.gene_tactic_lever)
                }
                Write-Host ("--- total {0} (showing last 40)" -f $rows.Count) -ForegroundColor DarkGray
            }
        } elseif ($sub -eq 'bans') {
            $b = Get-WpaiImproveBans
            $list = @($b.bans)
            if ($list.Count -eq 0) {
                Write-Host 'No bans. Run: wpai improve learn'
            } else {
                foreach ($ban in $list) {
                    Write-Output ("[{0}] {1}  {2}" -f $ban.kind, $ban.key, $ban.reason)
                }
                Write-Host ("--- {0} ban(s) updated {1}" -f $list.Count, $b.updated_at) -ForegroundColor DarkGray
            }
        } elseif ($sub -eq 'learning') {
            Write-Output (Get-WpaiImproveLearningReport)
        } elseif ($sub -eq 'self-inject' -or $sub -eq 'selfinject') {
            $extra = if ($Inject -gt 0) { $Inject } elseif ($map.ContainsKey('ExtraMutants')) { [int]$map['ExtraMutants'] } else { 40 }
            $r = Invoke-WpaiImproveSelfInject -ExtraMutants $extra -ReplaceCatalog:$Force
            Write-Host ("self-inject: catalog={0} injected={1} skipped_banned={2}" -f $r.count, $r.injected, $r.skipped_banned) -ForegroundColor Green
        } elseif ($sub -eq 'auto') {
            $lim = if ($AutoLimit -gt 0) { $AutoLimit } elseif ($Limit -gt 0) { $Limit } elseif ($map.ContainsKey('Limit')) { [int]$map['Limit'] } elseif ($map.ContainsKey('AutoLimit')) { [int]$map['AutoLimit'] } else { 12 }
            $r = Invoke-WpaiImproveAutoWave -Limit $lim -SelfOnly:$SelfOnly -Force:$Force
            Write-Host ("auto-wave gen {0}: {1} attempted · {2}S / {3}K / {4}I · skipped={5}" -f `
                $r.generation, $r.attempted, $r.supported, $r.killed, $r.inconclusive, $r.skipped) -ForegroundColor Green
            foreach ($x in $r.results) {
                if ($x.skipped) {
                    Write-Host ("  [SKIP] {0}  {1}" -f $x.path_id, $x.note) -ForegroundColor DarkGray
                    continue
                }
                $col = if ($x.verdict -eq 'SUPPORTED') { 'Green' } elseif ($x.verdict -eq 'KILLED') { 'Red' } else { 'Yellow' }
                $et = if ($x.evidence_tier) { $x.evidence_tier } else { '?' }
                Write-Host ("  [{0}/{1}] {2}  {3}/{4}  {5}" -f $x.verdict, $et, $x.path_id, $x.target, $x.tactic, $x.note) -ForegroundColor $col
            }
            Write-Host 'Next: wpai improve learn'
        } elseif ($sub -eq 'unleash') {
            $wv = if ($Waves -gt 0) { $Waves } elseif ($map.ContainsKey('Waves')) { [int]$map['Waves'] } else { 2 }
            $topN = if ($Top -gt 0) { $Top } elseif ($map.ContainsKey('Top')) { [int]$map['Top'] } else { 40 }
            $probeN = if ($Probe -gt 0) { $Probe } elseif ($map.ContainsKey('Probe')) { [int]$map['Probe'] } else { 16 }
            $lim = if ($AutoLimit -gt 0) { $AutoLimit } elseif ($map.ContainsKey('AutoLimit')) { [int]$map['AutoLimit'] } else { 12 }
            $k = if ($Keep -gt 0) { $Keep } elseif ($map.ContainsKey('Keep')) { [int]$map['Keep'] } else { 28 }
            $inj = if ($Inject -gt 0) { $Inject } elseif ($map.ContainsKey('Inject')) { [int]$map['Inject'] } else { 60 }
            $br = if ($Briefs -gt 0) { $Briefs } elseif ($map.ContainsKey('Briefs')) { [int]$map['Briefs'] } else { 8 }
            Write-Host ("UNLEASH: waves={0} autoLimit={1} (swarm → self)" -f $wv, $lim) -ForegroundColor Magenta
            $r = Invoke-WpaiImproveUnleash -Waves $wv -Top $topN -Probe $probeN -AutoLimit $lim -Keep $k -Inject $inj -Briefs $br -SelfOnlyAuto:$SelfOnly
            Write-Host ("done: gen={0} wall={1}s supported={2} killed={3}" -f $r.final_generation, $r.wall_sec, $r.total_supported, $r.total_killed) -ForegroundColor Green
            Write-Host ("report: {0}" -f $r.unleash_path)
            foreach ($wr in $r.reports) {
                Write-Host ("  wave {0} gen {1}: auto {2}S/{3}K/{4}I skip={5}  killRate={6}% var={7} elites={8}" -f `
                    $wr.wave, $wr.generation, $wr.auto_supported, $wr.auto_killed, $wr.auto_inconclusive, `
                    $wr.auto_skipped, $wr.kill_rate_pct, $wr.score_variance, $wr.elites_total) -ForegroundColor Cyan
            }
            if ($null -ne $r.shipped) {
                $tc = if ($r.unit_tests_ok -eq $true) { 'PASS' } elseif ($r.unit_tests_ok -eq $false) { 'FAIL' } else { '?' }
                Write-Host ("review: SHIPPED={0} PROPERTY={1} IDEA={2} unit_tests={3}" -f $r.shipped, $r.property, $r.idea, $tc) -ForegroundColor Yellow
                if ($r.review_path) { Write-Host ("review: {0}" -f $r.review_path) }
            }
            $metaPath = Join-Path (Get-WpaiImproveRuntimeDir) 'META.md'
            if (Test-Path $metaPath) { Write-Host ("meta: {0}" -f $metaPath) }
        } elseif ($sub -eq 'elite' -or $sub -eq 'elites') {
            $el = Update-WpaiImproveEliteArchive
            $doc = Get-WpaiImproveElites
            Write-Host ("elites: {0} (added now {1}) @ {2}" -f $el.count, $el.added, $el.path) -ForegroundColor Green
            foreach ($e in @($doc.elites | Select-Object -First 30)) {
                Write-Output ("  {0}  {1}/{2}/{3}  {4}" -f $e.path_id, $e.target, $e.lever, $e.tactic, $e.note)
            }
        } elseif ($sub -eq 'purge') {
            $r = Invoke-WpaiImprovePurgeTrash -WhatIf:$WhatIf
            Write-Host ("purge: before={0} kept={1} trashed={2} whatIf={3}" -f $r.before, $r.kept, $r.trashed, $r.what_if) -ForegroundColor Yellow
            if (-not $r.what_if) {
                Write-Host ("bans={0} elites={1} archive={2}" -f $r.learn_bans, $r.elites, $r.archive) -ForegroundColor Green
            }
        } elseif ($sub -eq 'doctor' -or $sub -eq 'reliability') {
            $r = Test-WpaiImproveReliability
            if ($r.ok) {
                $tc = if ($r.unit_tests_ok -eq $true) { 'PASS' } elseif ($r.unit_tests_ok -eq $false) { 'FAIL' } else { 'n/a' }
                Write-Host ("RELIABLE: outcomes={0} elites={1} bans={2} kills={3} shipped={4} tests={5}" -f `
                    $r.outcomes, $r.elites, $r.bans, $r.kills, $r.shipped, $tc) -ForegroundColor Green
                if ($r.review_path) { Write-Host ("review: {0}" -f $r.review_path) }
            } else {
                Write-Host ("NOT RELIABLE: outcomes={0} elites={1} bans={2}" -f $r.outcomes, $r.elites, $r.bans) -ForegroundColor Red
                foreach ($iss in $r.issues) { Write-Host ("  - {0}" -f $iss) -ForegroundColor Red }
            }
        } elseif ($sub -eq 'review') {
            $skipT = $SkipTests -or ($map.ContainsKey('SkipTests') -and $map['SkipTests'])
            $r = Invoke-WpaiImproveAutoReview -TopLeaders $(if ($Top -gt 0) { $Top } else { 12 }) -SkipTests:$skipT
            Write-Host ("SELF-REVIEW: SHIPPED={0} PROPERTY={1} IDEA={2} KILLED={3}" -f $r.shipped, $r.property, $r.idea, $r.killed) -ForegroundColor Cyan
            $tc = if ($r.unit_tests_ok -eq $true) { 'PASS' } elseif ($r.unit_tests_ok -eq $false) { 'FAIL' } else { 'skipped' }
            Write-Host ("unit tests: {0} ({1}ms)" -f $tc, $r.unit_tests_ms)
            Write-Host ("producing: {0}" -f $r.producing) -ForegroundColor Yellow
            Write-Host ("report: {0}" -f $r.path)
            # Print compact table
            $r.rows | Where-Object { $_.scope -eq 'elite' } | ForEach-Object {
                $col = switch ($_.kind) { 'SHIPPED' { 'Green' } 'KILLED' { 'Red' } 'PROPERTY' { 'DarkCyan' } default { 'DarkGray' } }
                Write-Host ("  [{0}] {1}  {2}" -f $_.kind, $_.path_id, $_.class) -ForegroundColor $col
            }
            $ideas = @($r.rows | Where-Object { $_.scope -eq 'leader' -and $_.kind -eq 'IDEA' }).Count
            if ($ideas -gt 0) {
                Write-Host ("  ... {0} leader rows are IDEA (hypotheses, not ships)" -f $ideas) -ForegroundColor DarkGray
            }
        } else {
            throw 'improve sub: seed | generation | leaders | briefs | mutate | record | learn | run | self-inject | auto | unleash | status | outcomes | bans | learning | elite | purge | doctor | review'
        }
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
