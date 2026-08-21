# Deep Research adapter — funding-gated; never runs forever without ticket.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-WpaiResearchAllowed {
    $bb = Get-WpaiBlackboard
    $ar = $bb.divisions.ai_research
    if ($null -eq $ar) { return @{ ok = $false; reason = 'ai_research block missing' } }
    if ([string]$ar.state -eq 'dormant') {
        return @{ ok = $false; reason = 'ai_research dormant — Director must activate' }
    }
    if ($ar.revenue_covers_compute -ne $true) {
        return @{ ok = $false; reason = 'revenue_covers_compute not attested' }
    }
    if ([double]$ar.compute_budget_usd_month -le 0) {
        return @{ ok = $false; reason = 'compute_budget_usd_month must be > 0' }
    }
    if (Test-WpaiKillActive -Blackboard $bb -Kind 'research') {
        return @{ ok = $false; reason = 'research kill switch on' }
    }
    if (Test-WpaiKillActive -Blackboard $bb -Kind 'global') {
        return @{ ok = $false; reason = 'global kill switch on' }
    }
    # Require pending-or-approved research_enable ticket
    $tickets = @(Get-WpaiApprovalTickets)
    $okTicket = $false
    $allowForever = $false
    foreach ($t in $tickets) {
        if ($t.kind -ne 'research_enable') { continue }
        if ($t.status -notin @('pending', 'approved')) { continue }
        $okTicket = $true
        try {
            if ($t.ticket.payload.allow_forever -eq $true -and $t.status -eq 'approved') {
                $allowForever = $true
            }
        } catch { }
    }
    if (-not $okTicket) {
        return @{ ok = $false; reason = 'need research_enable approval ticket (wpai research request)' }
    }
    return @{
        ok            = $true
        reason        = 'ok'
        allow_forever = $allowForever
        budget        = [double]$ar.compute_budget_usd_month
    }
}

function Request-WpaiResearchEnable {
    param(
        [double]$BudgetUsdMonth = 20,
        [switch]$AllowForever
    )
    $created = New-WpaiApprovalTicket -Kind 'research_enable' `
        -Summary ("Enable AI Research compute budget USD {0}/mo" -f $BudgetUsdMonth) `
        -Division 'ai_research' -RequestedBy 'director' -Payload @{
        compute_budget_usd_month = $BudgetUsdMonth
        allow_forever            = [bool]$AllowForever
    }
    Register-WpaiPendingApproval -TicketId $created.Ticket.id
    return $created
}

function Start-WpaiResearchRun {
    param(
        [int]$MetaGenerations = 3,
        [switch]$DryRun
    )
    $gate = Test-WpaiResearchAllowed
    if (-not $gate.ok) { throw $gate.reason }
    if ($MetaGenerations -eq 0 -and -not $gate.allow_forever) {
        throw 'META_GENERATIONS=0 (forever) requires approved research_enable ticket with allow_forever=true'
    }
    $root = 'C:\WPAI\AI-Research\deep_research_engine'
    if (-not (Test-Path -LiteralPath $root)) {
        throw "deep_research_engine not found at $root"
    }
    if ($DryRun) {
        return [pscustomobject]@{
            dry_run          = $true
            meta_generations = $MetaGenerations
            root             = $root
            message          = 'Would launch research engine (no money/API beyond local Ollama). Prestige: archive stuck genome before reset; META_GENERATIONS=0 blocked unless allow_forever ticket. HITL: approve research_enable ticket before real run.'
        }
    }
    $env:META_GENERATIONS = [string]$MetaGenerations
    Write-WpaiLog -Name 'research' -Message ("START meta={0}" -f $MetaGenerations)
    Invoke-WpaiBlackboardRmw -Mutator {
        param($bb)
        Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'research.run' -Division 'ai_research' -Actor 'bridge' -Refs @{
            meta_generations = $MetaGenerations
        }
    } | Out-Null
    # Local only — no cloud bill. User/Ollama compute only.
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'python'
    $psi.Arguments = 'main.py'
    $psi.WorkingDirectory = $root
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    try {
        $p = [System.Diagnostics.Process]::Start($psi)
        $out = $p.StandardOutput.ReadToEnd()
        $err = $p.StandardError.ReadToEnd()
        $p.WaitForExit()
        Write-WpaiLog -Name 'research' -Message ("END exit={0}" -f $p.ExitCode)
        return [pscustomobject]@{
            dry_run   = $false
            exit_code = $p.ExitCode
            stdout    = $out
            stderr    = $err
        }
    } catch {
        throw "Failed to start research engine: $($_.Exception.Message)"
    }
}
