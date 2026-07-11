# WPAI studio control-plane core — pure helpers for config, BLACKBOARD RMW, events, approvals.
# Dot-source from wpai.ps1. No network. Single-writer RMW for BLACKBOARD.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:WpaiWorkspaceRoot = 'C:\WPAI\Workspace'
$script:WpaiDir = Join-Path $script:WpaiWorkspaceRoot '.wpai'
$script:WpaiConfigPath = Join-Path $script:WpaiDir 'config.json'
$script:WpaiBlackboardPath = Join-Path $script:WpaiDir 'BLACKBOARD.json'
$script:WpaiApprovalsDir = Join-Path $script:WpaiDir 'approvals'
$script:WpaiDraftsDir = Join-Path $script:WpaiDir 'drafts'
$script:WpaiLogsDir = Join-Path $script:WpaiDir 'logs'
$script:WpaiPlansDir = Join-Path $script:WpaiDir 'plans'
$script:WpaiOvernightPath = Join-Path $script:WpaiDir 'overnight-plan.json'
$script:CostModelV0 = @{
    ROUND_FEE_USD    = 1.00
    EXECUTOR_FEE_USD = 0.50
    PLAN_FEE_USD     = 0.25
    version          = 'v0'
}

function Get-WpaiUtcNow {
    return [DateTime]::UtcNow.ToString('o')
}

function New-WpaiId {
    return ([guid]::NewGuid().ToString('N').Substring(0, 12))
}

function Get-WpaiDefaultConfig {
    return [ordered]@{
        schema_version      = '1.0.0'
        janus_root          = 'C:\WPAI\AI-Research\Janus'
        aether_tasks_path   = 'C:\WPAI\AI-Research\Janus\.aether\tasks.json'
        janus_cli           = 'node C:\WPAI\AI-Research\Janus\Project-Janus\packages\cli\dist\bin.js'
        assets_root         = 'C:\WPAI\AI-Research\AssetConverter'
        music_root          = 'C:\WPAI\Music'
        music_release_next  = 'Weaponized Mind'
        hellforge_dir       = 'C:\WPAI\Workspace\.hellforge'
        blackboard_path     = 'C:\WPAI\Workspace\.wpai\BLACKBOARD.json'
        wpai_dir            = 'C:\WPAI\Workspace\.wpai'
        cost_model_version  = 'v0'
        bridge_poll_seconds = 30
    }
}

function Get-WpaiDefaultBlackboard {
    $day = (Get-Date).ToString('yyyy-MM-dd')
    $month = (Get-Date).ToString('yyyy-MM')
    return [ordered]@{
        schema_version = '1.0.0'
        generation     = 1
        updated_at     = (Get-WpaiUtcNow)
        director_goal  = 'Ship Weaponized Mind package-ready; budgeted overnight only when armed'
        kill_switch    = [ordered]@{
            global    = $false
            loops     = $false
            research  = $false
            publishes = $false
        }
        budgets = [ordered]@{
            period_day                    = $day
            period_month                  = $month
            api_usd_cap_day               = 5.0
            api_usd_cap_month             = 40.0
            api_usd_spent_est_day         = 0.0
            api_usd_spent_est_month       = 0.0
            max_overnight_rounds          = 10
            max_executor_invocations_day  = 30
            executor_invocations_day      = 0
            max_parallel_workloads        = 1
            cost_model_version            = 'v0'
        }
        overnight = [ordered]@{
            armed           = $false
            parent_task_ids = @()
            max_rounds      = 10
            armed_by        = $null
            armed_at        = $null
            expires_at      = $null
            last_run        = $null
        }
        divisions = [ordered]@{
            music = [ordered]@{ state = 'active'; queue_depth = 0; last_event = $null }
            graphics = [ordered]@{ state = 'support'; queue_depth = 0; last_event = $null }
            gaming = [ordered]@{ state = 'active_external'; queue_depth = 0; last_event = $null }
            software = [ordered]@{ state = 'internal'; queue_depth = 0; last_event = $null }
            ai_research = [ordered]@{
                state                   = 'dormant'
                activation              = 'director_checklist'
                compute_budget_usd_month = 0
                revenue_covers_compute  = $false
                activated_by            = $null
                activated_at            = $null
                queue_depth             = 0
            }
            quantum = [ordered]@{ state = 'dormant'; activation = 'post_research' }
        }
        janus = [ordered]@{
            cli_path     = 'node C:\WPAI\AI-Research\Janus\Project-Janus\packages\cli\dist\bin.js'
            parents      = @()
            open_tasks   = 0
            failed_tasks = 0
            last_loop    = $null
        }
        pipelines = [ordered]@{
            music_release = [ordered]@{
                next            = 'Weaponized Mind'
                checklist_pass  = $false
                hitl_required   = $true
            }
            omni32 = [ordered]@{
                queue_depth = 0
                last_mod    = $null
                assets_root = 'C:\WPAI\AI-Research\AssetConverter'
            }
            software_storefront = [ordered]@{ repoforge = 'live'; mfm = 'live' }
            revenue = [ordered]@{ notes = 'manual; no auto-scrape Phases 0-3' }
        }
        approvals_pending = @()
        events            = @()
    }
}

function ConvertTo-WpaiJson {
    param([Parameter(Mandatory)]$Object, [int]$Depth = 20)
    return ($Object | ConvertTo-Json -Depth $Depth -Compress:$false)
}

function Read-WpaiJsonFile {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding utf8
    if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
    return ($raw | ConvertFrom-Json)
}

function Write-WpaiJsonAtomic {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)]$Object
    )
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $json = ConvertTo-WpaiJson -Object $Object
    $tmp = '{0}.tmp.{1}' -f $Path, $PID
    # UTF8 no BOM for machine JSON
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($tmp, $json, $utf8)
    # Windows: replace target
    if (Test-Path -LiteralPath $Path) {
        Move-Item -LiteralPath $tmp -Destination $Path -Force
    } else {
        Move-Item -LiteralPath $tmp -Destination $Path -Force
    }
}

function Ensure-WpaiRuntime {
    param([switch]$ForceTemplates)
    $cfgDefault = Get-WpaiDefaultConfig
    $bbDefault = Get-WpaiDefaultBlackboard
    $dirs = @(
        $script:WpaiDir,
        $script:WpaiApprovalsDir,
        (Join-Path $script:WpaiDraftsDir 'music'),
        (Join-Path $script:WpaiDraftsDir 'graphics'),
        $script:WpaiLogsDir,
        $script:WpaiPlansDir,
        (Join-Path $script:WpaiDir 'exports')
    )
    foreach ($d in $dirs) {
        if (-not (Test-Path -LiteralPath $d)) {
            New-Item -ItemType Directory -Force -Path $d | Out-Null
        }
    }
    if ($ForceTemplates -or -not (Test-Path -LiteralPath $script:WpaiConfigPath)) {
        Write-WpaiJsonAtomic -Path $script:WpaiConfigPath -Object $cfgDefault
    }
    if ($ForceTemplates -or -not (Test-Path -LiteralPath $script:WpaiBlackboardPath)) {
        Write-WpaiJsonAtomic -Path $script:WpaiBlackboardPath -Object $bbDefault
    }
    if (-not (Test-Path -LiteralPath $script:WpaiOvernightPath)) {
        $ov = [ordered]@{
            schema_version  = '1.0.0'
            armed           = $false
            parent_task_ids = @()
            max_rounds      = 10
            armed_by        = $null
            armed_at        = $null
            expires_at      = $null
        }
        Write-WpaiJsonAtomic -Path $script:WpaiOvernightPath -Object $ov
    }
    return [pscustomobject]@{
        WpaiDir     = $script:WpaiDir
        ConfigPath  = $script:WpaiConfigPath
        Blackboard  = $script:WpaiBlackboardPath
        Approvals   = $script:WpaiApprovalsDir
    }
}

function Get-WpaiConfig {
    Ensure-WpaiRuntime | Out-Null
    $cfg = Read-WpaiJsonFile -Path $script:WpaiConfigPath
    if ($null -eq $cfg) { return (Get-WpaiDefaultConfig | ConvertTo-Json -Depth 10 | ConvertFrom-Json) }
    return $cfg
}

function Get-WpaiConfigValue {
    param([string]$Name, $Default = $null)
    $cfg = Get-WpaiConfig
    $p = $cfg.PSObject.Properties[$Name]
    if ($null -eq $p -or $null -eq $p.Value -or [string]$p.Value -eq '') { return $Default }
    return $p.Value
}

function ConvertTo-WpaiHashtable {
    param($Object)
    if ($null -eq $Object) { return $null }
    if ($Object -is [hashtable] -or $Object -is [System.Collections.IDictionary]) { return $Object }
    if ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [string])) {
        $arr = @()
        foreach ($item in $Object) { $arr += ,(ConvertTo-WpaiHashtable $item) }
        return $arr
    }
    if ($Object -is [pscustomobject] -or $Object.GetType().Name -eq 'PSCustomObject') {
        $h = [ordered]@{}
        foreach ($p in $Object.PSObject.Properties) {
            $h[$p.Name] = ConvertTo-WpaiHashtable $p.Value
        }
        return $h
    }
    return $Object
}

function Enter-WpaiBlackboardLock {
    param([int]$TimeoutMs = 8000)
    Ensure-WpaiRuntime | Out-Null
    $lockPath = Join-Path $script:WpaiDir 'BLACKBOARD.lock'
    $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
    while ([DateTime]::UtcNow -lt $deadline) {
        try {
            # Exclusive create — fails if another process holds the lock file
            $fs = [System.IO.File]::Open(
                $lockPath,
                [System.IO.FileMode]::CreateNew,
                [System.IO.FileAccess]::Write,
                [System.IO.FileShare]::None
            )
            $bytes = [System.Text.Encoding]::UTF8.GetBytes(("{0} {1}" -f $PID, (Get-WpaiUtcNow)))
            $fs.Write($bytes, 0, $bytes.Length)
            return $fs
        } catch {
            Start-Sleep -Milliseconds (40 + (Get-Random -Maximum 80))
            # Stale lock recovery: if lock file older than 60s, delete and retry
            try {
                if (Test-Path -LiteralPath $lockPath) {
                    $age = (Get-Date) - (Get-Item -LiteralPath $lockPath).LastWriteTime
                    if ($age.TotalSeconds -gt 60) {
                        Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue
                    }
                }
            } catch { }
        }
    }
    throw "BLACKBOARD lock timeout after ${TimeoutMs}ms ($lockPath)"
}

function Exit-WpaiBlackboardLock {
    param($FileStream)
    $lockPath = Join-Path $script:WpaiDir 'BLACKBOARD.lock'
    try {
        if ($null -ne $FileStream) {
            $FileStream.Close()
            $FileStream.Dispose()
        }
    } catch { }
    try {
        if (Test-Path -LiteralPath $lockPath) {
            Remove-Item -LiteralPath $lockPath -Force -ErrorAction SilentlyContinue
        }
    } catch { }
}

function Invoke-WpaiBlackboardRmw {
    <#
    .SYNOPSIS
      Atomic single-writer RMW on BLACKBOARD.json with file lock + generation retries.
    .PARAMETER Mutator
      ScriptBlock receiving hashtable blackboard; mutates in place; returns nothing.
    #>
    param(
        [Parameter(Mandatory)][scriptblock]$Mutator,
        [int]$MaxRetries = 8
    )
    Ensure-WpaiRuntime | Out-Null
    $path = $script:WpaiBlackboardPath
    $lock = Enter-WpaiBlackboardLock
    try {
        $attempt = 0
        while ($attempt -lt $MaxRetries) {
            $attempt++
            $disk = Read-WpaiJsonFile -Path $path
            if ($null -eq $disk) {
                $disk = Get-WpaiDefaultBlackboard | ConvertTo-Json -Depth 20 | ConvertFrom-Json
            }
            $genBefore = 0
            try { $genBefore = [int]$disk.generation } catch { $genBefore = 0 }
            $bb = ConvertTo-WpaiHashtable $disk
            if ($null -eq $bb) { $bb = Get-WpaiDefaultBlackboard }

            # Roll day/month counters if period changed
            $today = (Get-Date).ToString('yyyy-MM-dd')
            $month = (Get-Date).ToString('yyyy-MM')
            if ($bb['budgets'] -is [System.Collections.IDictionary]) {
                if ([string]$bb['budgets']['period_day'] -ne $today) {
                    $bb['budgets']['period_day'] = $today
                    $bb['budgets']['api_usd_spent_est_day'] = 0.0
                    $bb['budgets']['executor_invocations_day'] = 0
                }
                if ([string]$bb['budgets']['period_month'] -ne $month) {
                    $bb['budgets']['period_month'] = $month
                    $bb['budgets']['api_usd_spent_est_month'] = 0.0
                }
            }

            & $Mutator $bb

            # Re-read generation for optimistic concurrency (belt + suspenders with lock)
            $disk2 = Read-WpaiJsonFile -Path $path
            $genNow = 0
            if ($null -ne $disk2) {
                try { $genNow = [int]$disk2.generation } catch { $genNow = 0 }
            }
            if ($genNow -ne $genBefore -and $attempt -lt $MaxRetries) {
                Start-Sleep -Milliseconds (30 * $attempt)
                continue
            }

            $bb['generation'] = $genBefore + 1
            $bb['updated_at'] = Get-WpaiUtcNow
            Write-WpaiJsonAtomic -Path $path -Object $bb
            return $bb
        }
        throw "BLACKBOARD RMW failed after $MaxRetries retries (generation conflict)."
    } finally {
        Exit-WpaiBlackboardLock -FileStream $lock
    }
}

function Get-WpaiBlackboard {
    Ensure-WpaiRuntime | Out-Null
    $bb = Read-WpaiJsonFile -Path $script:WpaiBlackboardPath
    if ($null -eq $bb) {
        Ensure-WpaiRuntime -ForceTemplates | Out-Null
        $bb = Read-WpaiJsonFile -Path $script:WpaiBlackboardPath
    }
    return $bb
}

function Add-WpaiEvent {
    param(
        [Parameter(Mandatory)][hashtable]$Blackboard,
        [Parameter(Mandatory)][string]$Kind,
        [string]$StepKey = '',
        [string]$Division = '',
        [string]$Actor = 'bridge',
        [hashtable]$Refs = @{}
    )
    $ev = [ordered]@{
        ts       = (Get-WpaiUtcNow)
        kind     = $Kind
        step_key = $StepKey
        division = $Division
        actor    = $Actor
        refs     = $Refs
    }
    $events = @()
    if ($Blackboard['events'] -is [System.Collections.IEnumerable] -and -not ($Blackboard['events'] -is [string])) {
        foreach ($e in $Blackboard['events']) { $events += ,$e }
    }
    $events += ,$ev
    # ring cap 200
    if ($events.Count -gt 200) {
        $events = $events[($events.Count - 200)..($events.Count - 1)]
    }
    $Blackboard['events'] = $events
}

function Test-WpaiKillActive {
    param($Blackboard, [string]$Kind = 'global')
    if ($null -eq $Blackboard) { $Blackboard = Get-WpaiBlackboard }
    $ks = $Blackboard.kill_switch
    if ($null -eq $ks) { return $false }
    if ($ks.global -eq $true) { return $true }
    if ($Kind -eq 'loops' -and $ks.loops -eq $true) { return $true }
    if ($Kind -eq 'research' -and $ks.research -eq $true) { return $true }
    if ($Kind -eq 'publishes' -and $ks.publishes -eq $true) { return $true }
    return $false
}

function Get-WpaiCostEstimate {
    param(
        [int]$Rounds = 1,
        [int]$ExecutorInvocations = 1,
        [switch]$IncludePlanFee
    )
    $c = $script:CostModelV0
    $total = ($Rounds * [double]$c.ROUND_FEE_USD) + ($ExecutorInvocations * [double]$c.EXECUTOR_FEE_USD)
    if ($IncludePlanFee) { $total += [double]$c.PLAN_FEE_USD }
    return [math]::Round($total, 2)
}

function Test-WpaiBudgetAllows {
    param(
        [Parameter(Mandatory)]$Blackboard,
        [double]$AdditionalUsd = 0,
        [int]$AdditionalInvocations = 0
    )
    $b = $Blackboard.budgets
    if ($null -eq $b) { return @{ ok = $false; reason = 'no budgets block' } }
    $daySpent = [double]$b.api_usd_spent_est_day + $AdditionalUsd
    $monthSpent = [double]$b.api_usd_spent_est_month + $AdditionalUsd
    $inv = [int]$b.executor_invocations_day + $AdditionalInvocations
    if ($daySpent -gt [double]$b.api_usd_cap_day) {
        return @{ ok = $false; reason = ("day spend est {0} would exceed cap {1}" -f $daySpent, $b.api_usd_cap_day) }
    }
    if ($monthSpent -gt [double]$b.api_usd_cap_month) {
        return @{ ok = $false; reason = ("month spend est {0} would exceed cap {1}" -f $monthSpent, $b.api_usd_cap_month) }
    }
    if ($inv -gt [int]$b.max_executor_invocations_day) {
        return @{ ok = $false; reason = ("invocations {0} would exceed day cap {1}" -f $inv, $b.max_executor_invocations_day) }
    }
    return @{ ok = $true; reason = 'ok' }
}

function New-WpaiApprovalTicket {
    param(
        [Parameter(Mandatory)][ValidateSet(
            'music_publish', 'pack_deploy', 'site_deploy', 'gumroad_listing',
            'research_enable', 'doctrine_change', 'overnight_arm', 'spend_raise', 'generic'
        )][string]$Kind,
        [Parameter(Mandatory)][string]$Summary,
        [string]$Division = '',
        [string]$RequestedBy = 'bridge',
        [string]$ParentTaskId = '',
        [string[]]$Paths = @(),
        [hashtable]$Payload = @{},
        [int]$ExpiresHours = 168,
        [switch]$AllowDuplicate
    )
    Ensure-WpaiRuntime | Out-Null
    # Dedupe: reuse pending ticket of same kind+summary (or music release name)
    if (-not $AllowDuplicate) {
        $pending = @(Get-WpaiApprovalTickets -Status 'pending')
        $releaseKey = $null
        if ($Payload -and $Payload.ContainsKey('release_name')) { $releaseKey = [string]$Payload['release_name'] }
        foreach ($p in $pending) {
            if ([string]$p.kind -ne $Kind) { continue }
            $sameSummary = [string]$p.summary -eq $Summary
            $sameRelease = $false
            if ($releaseKey -and $p.ticket -and $p.ticket.payload) {
                try {
                    $sameRelease = [string]$p.ticket.payload.release_name -eq $releaseKey
                } catch { }
            }
            if ($sameSummary -or $sameRelease) {
                return [pscustomobject]@{ Ticket = $p.ticket; Path = $p.path; Deduped = $true }
            }
        }
    }
    $id = 'appr-' + (New-WpaiId)
    $now = Get-Date
    $ticket = [ordered]@{
        schema_version  = '1.0.0'
        id              = $id
        kind            = $Kind
        status          = 'pending'
        summary         = $Summary
        division        = $Division
        requested_by    = $RequestedBy
        requested_at    = $now.ToUniversalTime().ToString('o')
        expires_at      = $now.AddHours($ExpiresHours).ToUniversalTime().ToString('o')
        parent_task_id  = $ParentTaskId
        paths           = @($Paths)
        payload         = $Payload
        decision        = $null
        decided_by      = $null
        decided_at      = $null
        deny_reason     = $null
        content_sha256  = $null
    }
    # content integrity over summary+paths
    $hasher = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes(($Summary + '|' + ($Paths -join '|')))
    $hash = ($hasher.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join ''
    $ticket['content_sha256'] = $hash
    $path = Join-Path $script:WpaiApprovalsDir ("{0}.json" -f $id)
    Write-WpaiJsonAtomic -Path $path -Object $ticket
    # Protocol bus telegram (short); ticket file remains SoT
    try {
        if (Get-Command Write-WpaiBusMessage -ErrorAction SilentlyContinue) {
            Write-WpaiBusMessage -Text ("approve_request: {0}" -f $Summary) -Type 'approve_request' `
                -From $RequestedBy -To 'director' -Path $path -Id $id | Out-Null
        }
    } catch { }
    return [pscustomobject]@{ Ticket = $ticket; Path = $path; Deduped = $false }
}

function Get-WpaiApprovalTickets {
    param([string]$Status = '')
    Ensure-WpaiRuntime | Out-Null
    $out = @()
    foreach ($f in Get-ChildItem -LiteralPath $script:WpaiApprovalsDir -Filter '*.json' -File -ErrorAction SilentlyContinue) {
        try {
            $t = Read-WpaiJsonFile -Path $f.FullName
            if ($null -eq $t) { continue }
            if ($Status -and [string]$t.status -ne $Status) { continue }
            $out += [pscustomobject]@{
                id           = $t.id
                kind         = $t.kind
                status       = $t.status
                summary      = $t.summary
                division     = $t.division
                requested_at = $t.requested_at
                path         = $f.FullName
                ticket       = $t
            }
        } catch { continue }
    }
    return $out | Sort-Object requested_at -Descending
}

function Set-WpaiApprovalDecision {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][ValidateSet('approved', 'rejected')][string]$Decision,
        [string]$By = 'director',
        [string]$DenyReason = ''
    )
    $path = Join-Path $script:WpaiApprovalsDir ("{0}.json" -f $Id)
    if (-not (Test-Path -LiteralPath $path)) {
        # allow bare id without prefix
        $cand = Get-ChildItem -LiteralPath $script:WpaiApprovalsDir -Filter "*$Id*.json" -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cand) { $path = $cand.FullName } else { throw "Approval ticket not found: $Id" }
    }
    $t = ConvertTo-WpaiHashtable (Read-WpaiJsonFile -Path $path)
    if ([string]$t['status'] -ne 'pending') {
        throw ("Ticket {0} already decided: {1}" -f $t['id'], $t['status'])
    }
    # expiry check
    try {
        $exp = [DateTime]::Parse([string]$t['expires_at']).ToUniversalTime()
        if ([DateTime]::UtcNow -gt $exp) {
            $t['status'] = 'expired'
            Write-WpaiJsonAtomic -Path $path -Object $t
            throw "Ticket expired: $($t['id'])"
        }
    } catch {
        if ($_.Exception.Message -like 'Ticket expired*') { throw }
    }
    $t['status'] = if ($Decision -eq 'approved') { 'approved' } else { 'rejected' }
    $t['decision'] = $Decision
    $t['decided_by'] = $By
    $t['decided_at'] = Get-WpaiUtcNow
    if ($Decision -eq 'rejected') { $t['deny_reason'] = $DenyReason }
    Write-WpaiJsonAtomic -Path $path -Object $t

    # Project pending ids into BLACKBOARD via RMW
    $tid = [string]$t['id']
    Invoke-WpaiBlackboardRmw -Mutator {
        param($bb)
        $pending = @()
        if ($bb['approvals_pending'] -is [System.Collections.IEnumerable]) {
            foreach ($p in $bb['approvals_pending']) {
                if ([string]$p -ne $tid) { $pending += [string]$p }
            }
        }
        $bb['approvals_pending'] = $pending
        Add-WpaiEvent -Blackboard $bb -Kind 'approval' -StepKey ("approval.{0}" -f $Decision) -Actor $By -Refs @{ approval_id = $tid }
    } | Out-Null

    try {
        if (Get-Command Write-WpaiBusMessage -ErrorAction SilentlyContinue) {
            Write-WpaiBusMessage -Text ("approve_result: {0} {1}" -f $tid, $Decision) -Type 'approve_result' `
                -From $By -To 'all' -Path $path -Id $tid | Out-Null
        }
    } catch { }

    return $t
}

function Register-WpaiPendingApproval {
    param([Parameter(Mandatory)][string]$TicketId)
    Invoke-WpaiBlackboardRmw -Mutator {
        param($bb)
        $pending = @()
        if ($bb['approvals_pending'] -is [System.Collections.IEnumerable]) {
            foreach ($p in $bb['approvals_pending']) { $pending += [string]$p }
        }
        if ($pending -notcontains $TicketId) { $pending += $TicketId }
        $bb['approvals_pending'] = $pending
    } | Out-Null
}

function Get-WpaiPendingApprovalIds {
    <#
    .SYNOPSIS
      Pending approval ticket ids only (one per line when written to host/pipeline).
    #>
    $ids = @(Get-WpaiApprovalTickets -Status 'pending' | ForEach-Object { [string]$_.id } | Where-Object { $_ })
    return $ids
}

function Remove-WpaiResolvedApprovals {
    <#
    .SYNOPSIS
      Delete approved/rejected/expired ticket files older than N days (default 7).
      Never deletes pending tickets. No network.
    #>
    param(
        [int]$OlderThanDays = 7,
        [switch]$WhatIf
    )
    if ($OlderThanDays -lt 0) { throw 'OlderThanDays must be >= 0' }
    Ensure-WpaiRuntime | Out-Null
    $cutoff = [DateTime]::UtcNow.AddDays(-1 * $OlderThanDays)
    $resolved = @('approved', 'rejected', 'expired')
    $deleted = [System.Collections.Generic.List[object]]::new()
    $skipped = 0
    foreach ($row in @(Get-WpaiApprovalTickets)) {
        $st = [string]$row.status
        if ($st -notin $resolved) {
            $skipped++
            continue
        }
        $t = $row.ticket
        $stamp = $null
        foreach ($field in @('decided_at', 'expires_at', 'requested_at')) {
            $raw = $null
            try { $raw = [string]$t.$field } catch { $raw = $null }
            if ([string]::IsNullOrWhiteSpace($raw)) { continue }
            try {
                $stamp = [DateTime]::Parse($raw).ToUniversalTime()
                break
            } catch { continue }
        }
        if ($null -eq $stamp) {
            try {
                $stamp = (Get-Item -LiteralPath $row.path).LastWriteTimeUtc
            } catch {
                $skipped++
                continue
            }
        }
        if ($stamp -gt $cutoff) {
            $skipped++
            continue
        }
        if ($WhatIf) {
            $deleted.Add([pscustomobject]@{
                    id     = $row.id
                    status = $st
                    path   = $row.path
                    age_ts = $stamp.ToString('o')
                    action = 'would_delete'
                }) | Out-Null
            continue
        }
        try {
            Remove-Item -LiteralPath $row.path -Force
            $deleted.Add([pscustomobject]@{
                    id     = $row.id
                    status = $st
                    path   = $row.path
                    age_ts = $stamp.ToString('o')
                    action = 'deleted'
                }) | Out-Null
        } catch {
            $skipped++
        }
    }
    return [pscustomobject]@{
        older_than_days = $OlderThanDays
        cutoff_utc      = $cutoff.ToString('o')
        deleted_count   = $deleted.Count
        skipped         = $skipped
        deleted         = @($deleted)
    }
}

function Get-WpaiPromotionCandidates {
    param([int]$WindowDays = 90, [int]$Threshold = 3)
    $bb = Get-WpaiBlackboard
    $cutoff = [DateTime]::UtcNow.AddDays(-$WindowDays)
    $counts = @{}
    if ($bb.events) {
        foreach ($e in $bb.events) {
            if ([string]$e.kind -ne 'manual_step') { continue }
            $sk = [string]$e.step_key
            if (-not $sk) { continue }
            try {
                $ts = [DateTime]::Parse([string]$e.ts).ToUniversalTime()
                if ($ts -lt $cutoff) { continue }
            } catch { continue }
            if (-not $counts.ContainsKey($sk)) { $counts[$sk] = 0 }
            $counts[$sk]++
        }
    }
    $cands = @()
    foreach ($k in $counts.Keys) {
        if ($counts[$k] -ge $Threshold) {
            $cands += [pscustomobject]@{ step_key = $k; count = $counts[$k]; threshold = $Threshold }
        }
    }
    return $cands
}

function Write-WpaiLog {
    param([string]$Name, [string]$Message)
    Ensure-WpaiRuntime | Out-Null
    $safe = ($Name -replace '[^\w\-]', '_')
    $path = Join-Path $script:WpaiLogsDir ("{0}.log" -f $safe)
    $line = '{0} {1}' -f (Get-WpaiUtcNow), $Message
    Add-Content -LiteralPath $path -Value $line -Encoding utf8
}
