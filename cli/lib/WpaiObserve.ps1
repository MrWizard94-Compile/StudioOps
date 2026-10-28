# WPAI observe — high-signal snapshots (read-only).
# Path path-5a2aa6fbdc7c: observability · janus-not-direct-write · slow-down-to-speed-up
#
# Policy:
#   - READ BLACKBOARD + optional .aether tasks; never rewrite workload trees.
#   - Append one JSON line to Workspace\.wpai\logs\observe.jsonl (no chat spam).
#   - Prefer event-driven bus over high-frequency polling (rate-limit note below).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Minimum recommended interval between snapshots (seconds). Faster = more I/O, less signal.
$script:WpaiObserveMinIntervalSeconds = 30
$script:WpaiObserveRateLimitNote =
    'RATE_LIMIT: high-frequency polling is worse than event-driven bus; sample >=30s or on bus events only. Prefer wpai bus / hellforge bus over tight observe loops.'

function Get-WpaiObserveLogPath {
    Ensure-WpaiRuntime | Out-Null
    return (Join-Path $script:WpaiLogsDir 'observe.jsonl')
}

function Get-WpaiAetherTaskCounts {
    <#
    .SYNOPSIS
      Read-only counts from .aether/tasks.json. Never mutates the task store.
    #>
    param([string]$TasksPath = '')
    if (-not $TasksPath) {
        $TasksPath = [string](Get-WpaiConfigValue -Name 'aether_tasks_path' -Default 'C:\WPAI\AI-Research\Janus\.aether\tasks.json')
    }
    $result = [ordered]@{
        path         = $TasksPath
        present      = $false
        total        = 0
        open         = 0
        failed       = 0
        done         = 0
        by_status    = [ordered]@{}
        parse_error  = $null
    }
    if (-not (Test-Path -LiteralPath $TasksPath)) { return $result }
    $result.present = $true
    try {
        $raw = Get-Content -LiteralPath $TasksPath -Raw -Encoding utf8
        $data = $raw | ConvertFrom-Json
        $tasks = @()
        if ($null -ne $data -and $data.PSObject.Properties['tasks']) {
            $tnode = $data.tasks
            if ($null -ne $tnode) {
                if ($tnode -is [System.Collections.IEnumerable] -and -not ($tnode -is [string]) -and -not ($tnode.PSObject.Properties.Name -contains 'id')) {
                    # array of tasks OR object map
                    $props = @($tnode.PSObject.Properties)
                    $isMap = $false
                    foreach ($p in $props) {
                        if ($p.Name -match '^\d+$' -or $p.Name -match '^[a-zA-Z]') {
                            # If first values look like task objects, treat as map
                            if ($null -ne $p.Value -and $p.Value.PSObject -and ($p.Value.PSObject.Properties['id'] -or $p.Value.PSObject.Properties['status'])) {
                                $isMap = $true
                                break
                            }
                        }
                    }
                    if ($isMap -or ($tnode -is [System.Collections.IDictionary])) {
                        foreach ($p in $tnode.PSObject.Properties) { $tasks += ,$p.Value }
                    } else {
                        $tasks = @($tnode)
                    }
                } elseif ($tnode.PSObject.Properties['id'] -or $tnode.PSObject.Properties['status']) {
                    $tasks = @($tnode)
                } else {
                    foreach ($p in $tnode.PSObject.Properties) { $tasks += ,$p.Value }
                }
            }
        } elseif ($null -ne $data -and $data -is [System.Collections.IEnumerable] -and -not ($data -is [string])) {
            $tasks = @($data)
        }
        $by = @{}
        foreach ($t in $tasks) {
            if ($null -eq $t) { continue }
            $st = ''
            if ($t -is [System.Collections.IDictionary]) {
                $st = [string]$t['status']
            } elseif ($t.PSObject.Properties['status']) {
                $st = [string]$t.status
            }
            if (-not $st) { $st = 'unknown' }
            if (-not $by.ContainsKey($st)) { $by[$st] = 0 }
            $by[$st]++
            $result.total++
            if ($st -in @('pending', 'in_progress', 'validating', 'accepted')) { $result.open++ }
            elseif ($st -eq 'failed') { $result.failed++ }
            elseif ($st -in @('done', 'completed', 'closed', 'resolved')) { $result.done++ }
        }
        $ordered = [ordered]@{}
        foreach ($k in ($by.Keys | Sort-Object)) { $ordered[$k] = $by[$k] }
        $result.by_status = $ordered
    } catch {
        $result.parse_error = $_.Exception.Message
    }
    return $result
}

function Get-WpaiObserveSnapshot {
    <#
    .SYNOPSIS
      One high-signal observability snapshot. Read-only w.r.t. BLACKBOARD and .aether.
    #>
    param(
        [switch]$SkipTasks,
        [string]$PathId = 'path-5a2aa6fbdc7c'
    )
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $bb = Get-WpaiBlackboard
    $cfg = Get-WpaiConfig

    $pending = @()
    try { $pending = @(Get-WpaiApprovalTickets -Status 'pending') } catch { $pending = @() }

    $taskCounts = $null
    if (-not $SkipTasks) {
        $taskCounts = Get-WpaiAetherTaskCounts
    }

    # High-signal projection only — not full BLACKBOARD dump
    $bbProj = [ordered]@{
        generation    = $bb.generation
        updated_at    = $bb.updated_at
        director_goal = $bb.director_goal
        kill_switch   = $bb.kill_switch
        overnight     = [ordered]@{
            armed           = $bb.overnight.armed
            max_rounds      = $bb.overnight.max_rounds
            parent_task_ids = @($bb.overnight.parent_task_ids)
        }
        budgets = [ordered]@{
            api_usd_spent_est_day   = $bb.budgets.api_usd_spent_est_day
            api_usd_cap_day         = $bb.budgets.api_usd_cap_day
            api_usd_spent_est_month = $bb.budgets.api_usd_spent_est_month
            api_usd_cap_month       = $bb.budgets.api_usd_cap_month
            executor_invocations_day = $bb.budgets.executor_invocations_day
            max_executor_invocations_day = $bb.budgets.max_executor_invocations_day
        }
        janus = [ordered]@{
            open_tasks   = $bb.janus.open_tasks
            failed_tasks = $bb.janus.failed_tasks
            last_loop    = $bb.janus.last_loop
        }
        music_checklist_pass = $bb.pipelines.music_release.checklist_pass
        approvals_pending_n  = $pending.Count
        ai_research_state    = $bb.divisions.ai_research.state
    }

    $sw.Stop()
    $snap = [ordered]@{
        schema_version      = '1.0.0'
        kind                = 'observe.snapshot'
        ts                  = (Get-WpaiUtcNow)
        path_id             = $PathId
        tactic              = 'janus-not-direct-write'
        invert              = 'slow-down-to-speed-up'
        write_policy        = 'append-observe-jsonl-only; no BLACKBOARD RMW; no .aether mutation; no workload tree rewrite'
        min_interval_seconds = $script:WpaiObserveMinIntervalSeconds
        rate_limit_note     = $script:WpaiObserveRateLimitNote
        latency_ms          = $sw.ElapsedMilliseconds
        blackboard          = $bbProj
        aether_tasks        = $taskCounts
        config_hint         = [ordered]@{
            bridge_poll_seconds = $(if ($cfg.PSObject.Properties['bridge_poll_seconds']) { $cfg.bridge_poll_seconds } else { 30 })
            aether_tasks_path   = $(if ($cfg.PSObject.Properties['aether_tasks_path']) { [string]$cfg.aether_tasks_path } else { '' })
        }
    }
    return $snap
}

function Write-WpaiObserveSnapshot {
    <#
    .SYNOPSIS
      Capture snapshot and append a single JSON line to observe.jsonl.
    #>
    param(
        [switch]$SkipTasks,
        [switch]$Quiet,
        [string]$PathId = 'path-5a2aa6fbdc7c'
    )
    $snap = Get-WpaiObserveSnapshot -SkipTasks:$SkipTasks -PathId $PathId
    $logPath = Get-WpaiObserveLogPath
    $dir = Split-Path -Parent $logPath
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $line = ($snap | ConvertTo-Json -Depth 12 -Compress)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::AppendAllText($logPath, ($line + [Environment]::NewLine), $utf8)

    if (-not $Quiet) {
        # Host only — keep pipeline clean so callers receive the return object.
        # One compact operator line — not a full dump (no chat spam).
        $openA = if ($null -ne $snap.aether_tasks) { $snap.aether_tasks.open } else { 'skip' }
        Write-Host ("observe.snapshot ts={0} gen={1} bb_open={2} aether_open={3} approvals={4} latency_ms={5} log={6}" -f `
            $snap.ts,
            $snap.blackboard.generation,
            $snap.blackboard.janus.open_tasks,
            $openA,
            $snap.blackboard.approvals_pending_n,
            $snap.latency_ms,
            $logPath)
        Write-Host $script:WpaiObserveRateLimitNote
    }

    return [pscustomobject]@{
        ok           = $true
        log_path     = $logPath
        latency_ms   = $snap.latency_ms
        generation   = $snap.blackboard.generation
        snapshot     = $snap
    }
}
