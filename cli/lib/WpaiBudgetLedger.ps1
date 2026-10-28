# WPAI budget ledger — double-entry style audit for spend estimates (blackboard, not chat).
# Path: Workspace\.wpai\logs\budget-ledger.jsonl
# Every charge/cap change writes two legs (debit + credit) linked by entry_id.
# No paid APIs. Dot-source after WpaiCore.ps1.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-WpaiBudgetLedgerPath {
    Ensure-WpaiRuntime | Out-Null
    return (Join-Path $script:WpaiLogsDir 'budget-ledger.jsonl')
}

function Write-WpaiBudgetLedgerPair {
    <#
    .SYNOPSIS
      Append a balanced double-entry pair to budget-ledger.jsonl.
    .DESCRIPTION
      Borrow-from-accounting: every estimated spend or cap mutation has a balancing audit leg.
      Agents read this ledger instead of multi-message bus chat for budget reconciliation.
    #>
    param(
        [Parameter(Mandatory)][string]$DebitAccount,
        [Parameter(Mandatory)][string]$CreditAccount,
        [Parameter(Mandatory)][double]$Amount,
        [string]$Memo = '',
        [string]$Actor = 'bridge',
        [string]$Kind = 'charge',
        [hashtable]$Meta = @{}
    )
    $path = Get-WpaiBudgetLedgerPath
    $entryId = 'ble-' + (New-WpaiId)
    $ts = Get-WpaiUtcNow
    $base = [ordered]@{
        ts        = $ts
        entry_id  = $entryId
        kind      = $Kind
        amount    = [math]::Round([double]$Amount, 4)
        memo      = $Memo
        actor     = $Actor
    }
    if ($Meta.Count -gt 0) {
        foreach ($k in $Meta.Keys) { $base[$k] = $Meta[$k] }
    }
    $debit = [ordered]@{}
    foreach ($k in $base.Keys) { $debit[$k] = $base[$k] }
    $debit['leg'] = 1
    $debit['side'] = 'debit'
    $debit['account'] = $DebitAccount

    $credit = [ordered]@{}
    foreach ($k in $base.Keys) { $credit[$k] = $base[$k] }
    $credit['leg'] = 2
    $credit['side'] = 'credit'
    $credit['account'] = $CreditAccount

    $utf8 = New-Object System.Text.UTF8Encoding $false
    $lines = @(
        ($debit | ConvertTo-Json -Compress -Depth 6)
        ($credit | ConvertTo-Json -Compress -Depth 6)
    )
    $dir = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    # Append both legs as one write where possible
    $payload = ($lines -join [Environment]::NewLine) + [Environment]::NewLine
    [System.IO.File]::AppendAllText($path, $payload, $utf8)
    return [pscustomobject]@{
        entry_id = $entryId
        path     = $path
        amount   = [double]$Amount
        kind     = $Kind
        debit    = $DebitAccount
        credit   = $CreditAccount
    }
}

function Get-WpaiBudgetLedgerSummary {
    <#
    .SYNOPSIS
      Day/month spent vs caps from BLACKBOARD + optional recent ledger tails.
    #>
    param([int]$Tail = 10)
    $bb = Get-WpaiBlackboard
    $b = $bb.budgets
    if ($null -eq $b) { throw 'BLACKBOARD missing budgets block' }

    $daySpent = [double]$b.api_usd_spent_est_day
    $dayCap = [double]$b.api_usd_cap_day
    $monthSpent = [double]$b.api_usd_spent_est_month
    $monthCap = [double]$b.api_usd_cap_month
    $dayRem = [math]::Round($dayCap - $daySpent, 4)
    $monthRem = [math]::Round($monthCap - $monthSpent, 4)

    $ledgerPath = Get-WpaiBudgetLedgerPath
    $recent = @()
    $lineCount = 0
    if (Test-Path -LiteralPath $ledgerPath) {
        $all = @(Get-Content -LiteralPath $ledgerPath -Encoding utf8 | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $lineCount = $all.Count
        if ($Tail -gt 0 -and $all.Count -gt 0) {
            $slice = if ($all.Count -le $Tail) { $all } else { $all[($all.Count - $Tail)..($all.Count - 1)] }
            foreach ($line in $slice) {
                try { $recent += , ($line | ConvertFrom-Json) } catch { }
            }
        }
    }

    return [pscustomobject]@{
        schema           = 'wpai-budget-ledger-summary/v1'
        period_day       = [string]$b.period_day
        period_month     = [string]$b.period_month
        day_spent_usd    = $daySpent
        day_cap_usd      = $dayCap
        day_remaining    = $dayRem
        month_spent_usd  = $monthSpent
        month_cap_usd    = $monthCap
        month_remaining  = $monthRem
        inv_day          = [int]$b.executor_invocations_day
        inv_cap_day      = [int]$b.max_executor_invocations_day
        cost_model       = [string]$b.cost_model_version
        ledger_path      = $ledgerPath
        ledger_lines     = $lineCount
        recent           = $recent
        blackboard_gen   = [int]$bb.generation
    }
}

function Show-WpaiBudgetLedger {
    param([int]$Tail = 10)
    $s = Get-WpaiBudgetLedgerSummary -Tail $Tail
    # Host stream so callers can pipe/Out-Null the return object without hiding the printout
    Write-Host ("BUDGET LEDGER  day {0}/{1} USD (rem {2})  month {3}/{4} USD (rem {5})" -f `
            $s.day_spent_usd, $s.day_cap_usd, $s.day_remaining, `
            $s.month_spent_usd, $s.month_cap_usd, $s.month_remaining)
    Write-Host ("inv {0}/{1}  model={2}  period={3}/{4}  bb.gen={5}" -f `
            $s.inv_day, $s.inv_cap_day, $s.cost_model, $s.period_day, $s.period_month, $s.blackboard_gen)
    Write-Host ("ledger: {0}  lines={1}" -f $s.ledger_path, $s.ledger_lines)
    if ($s.recent.Count -gt 0) {
        Write-Host '--- recent double-entry legs ---'
        foreach ($r in $s.recent) {
            Write-Host ("  {0}  {1} leg{2} {3,-6} {4,-28} {5,8}  {6}" -f `
                    $r.ts, $r.entry_id, $r.leg, $r.side, $r.account, $r.amount, $r.memo)
        }
    } else {
        Write-Host '(ledger empty — charge or set-day/set-month to append balanced pairs)'
    }
    return $s
}

function Add-WpaiBudgetCharge {
    <#
    .SYNOPSIS
      Dry charge helper: record estimated spend on BLACKBOARD + balanced ledger pair.
      Does not call paid APIs. Fails closed if budget gate would exceed caps.
    #>
    param(
        [double]$Usd = 0,
        [int]$Invocations = 0,
        [string]$Memo = 'dry charge',
        [string]$Actor = 'bridge',
        [switch]$DryRun,
        [switch]$SkipGate
    )
    if ($Usd -lt 0) { throw 'Usd must be >= 0' }
    if ($Invocations -lt 0) { throw 'Invocations must be >= 0' }
    if ($Usd -eq 0 -and $Invocations -eq 0) {
        $Usd = [double](Get-WpaiCostEstimate -Rounds 1 -ExecutorInvocations 1)
        $Invocations = 1
        if ([string]::IsNullOrWhiteSpace($Memo) -or $Memo -eq 'dry charge') {
            $Memo = 'dry charge (cost model v0 default 1r+1e)'
        }
    }

    $bb = Get-WpaiBlackboard
    if (-not $SkipGate) {
        $allow = Test-WpaiBudgetAllows -Blackboard $bb -AdditionalUsd $Usd -AdditionalInvocations $Invocations
        if (-not $allow.ok) { throw $allow.reason }
    }

    if ($DryRun) {
        $pair = Write-WpaiBudgetLedgerPair `
            -DebitAccount 'api_usd_spent_est' `
            -CreditAccount 'budget_reserve' `
            -Amount $Usd `
            -Memo ("DRYRUN: $Memo") `
            -Actor $Actor `
            -Kind 'charge_dryrun' `
            -Meta @{
                invocations = $Invocations
                applied     = $false
            }
        return [pscustomobject]@{
            applied      = $false
            dry_run      = $true
            usd          = $Usd
            invocations  = $Invocations
            entry_id     = $pair.entry_id
            ledger_path  = $pair.path
            day_after    = $null
            month_after  = $null
        }
    }

    $chargeUsd = $Usd
    $chargeInv = $Invocations
    $memoCapture = $Memo
    $actorCapture = $Actor
    $after = Invoke-WpaiBlackboardRmw -Mutator {
        param($b)
        $b['budgets']['api_usd_spent_est_day'] = [double]$b['budgets']['api_usd_spent_est_day'] + $chargeUsd
        $b['budgets']['api_usd_spent_est_month'] = [double]$b['budgets']['api_usd_spent_est_month'] + $chargeUsd
        $b['budgets']['executor_invocations_day'] = [int]$b['budgets']['executor_invocations_day'] + $chargeInv
        Add-WpaiEvent -Blackboard $b -Kind 'budget' -StepKey 'budget.charge' -Actor $actorCapture -Refs @{
            usd         = $chargeUsd
            invocations = $chargeInv
            memo        = $memoCapture
        }
    }

    $pair = Write-WpaiBudgetLedgerPair `
        -DebitAccount 'api_usd_spent_est' `
        -CreditAccount 'budget_reserve' `
        -Amount $chargeUsd `
        -Memo $memoCapture `
        -Actor $actorCapture `
        -Kind 'charge' `
        -Meta @{
            invocations   = $chargeInv
            day_spent     = [double]$after['budgets']['api_usd_spent_est_day']
            month_spent   = [double]$after['budgets']['api_usd_spent_est_month']
            applied       = $true
            bb_generation = [int]$after['generation']
        }

    return [pscustomobject]@{
        applied      = $true
        dry_run      = $false
        usd          = $chargeUsd
        invocations  = $chargeInv
        entry_id     = $pair.entry_id
        ledger_path  = $pair.path
        day_after    = [double]$after['budgets']['api_usd_spent_est_day']
        month_after  = [double]$after['budgets']['api_usd_spent_est_month']
    }
}

function Write-WpaiBudgetCapChange {
    <#
    .SYNOPSIS
      Record a cap mutation as a balanced ledger pair (authorization vs reserve).
    #>
    param(
        [Parameter(Mandatory)][ValidateSet('day', 'month')][string]$Period,
        [Parameter(Mandatory)][double]$NewCap,
        [double]$OldCap = 0,
        [string]$Actor = 'director'
    )
    $account = if ($Period -eq 'day') { 'api_usd_cap_day' } else { 'api_usd_cap_month' }
    $delta = [math]::Abs($NewCap - $OldCap)
    if ($delta -eq 0) { $delta = 0.0001 } # still audit zero-diff sets
    $debit = if ($NewCap -ge $OldCap) { $account } else { 'director_authorization' }
    $credit = if ($NewCap -ge $OldCap) { 'director_authorization' } else { $account }
    return Write-WpaiBudgetLedgerPair `
        -DebitAccount $debit `
        -CreditAccount $credit `
        -Amount $delta `
        -Memo ("set-$Period cap $OldCap -> $NewCap") `
        -Actor $Actor `
        -Kind 'cap_change' `
        -Meta @{
            period  = $Period
            old_cap = $OldCap
            new_cap = $NewCap
        }
}

function Test-WpaiBudgetLedgerBalance {
    <#
    .SYNOPSIS
      Self-check: for each entry_id, debit sum == credit sum (grep-fit style).
    #>
    param([string]$Path = '')
    if (-not $Path) { $Path = Get-WpaiBudgetLedgerPath }
    if (-not (Test-Path -LiteralPath $Path)) {
        return [pscustomobject]@{ ok = $true; entries = 0; unbalanced = @(); reason = 'empty ledger' }
    }
    $byId = @{}
    $lines = Get-Content -LiteralPath $Path -Encoding utf8 | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    foreach ($line in $lines) {
        try {
            $o = $line | ConvertFrom-Json
            $id = [string]$o.entry_id
            if (-not $byId.ContainsKey($id)) {
                $byId[$id] = @{ debit = 0.0; credit = 0.0 }
            }
            $amt = [double]$o.amount
            if ([string]$o.side -eq 'debit') { $byId[$id].debit += $amt }
            elseif ([string]$o.side -eq 'credit') { $byId[$id].credit += $amt }
        } catch { }
    }
    $unbalanced = @()
    foreach ($id in $byId.Keys) {
        $d = [math]::Round($byId[$id].debit, 4)
        $c = [math]::Round($byId[$id].credit, 4)
        if ($d -ne $c) { $unbalanced += $id }
    }
    return [pscustomobject]@{
        ok          = ($unbalanced.Count -eq 0)
        entries     = $byId.Count
        unbalanced  = $unbalanced
        reason      = if ($unbalanced.Count -eq 0) { 'balanced' } else { 'unbalanced entry_ids' }
    }
}
