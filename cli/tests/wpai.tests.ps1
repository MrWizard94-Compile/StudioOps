# WPAI control-plane self-tests (PowerShell)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$failed = 0
function Assert-True($cond, $msg) {
    if (-not $cond) {
        Write-Host "FAIL: $msg" -ForegroundColor Red
        $script:failed++
    } else {
        Write-Host "ok  : $msg" -ForegroundColor DarkGreen
    }
}

$cli = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
. (Join-Path $cli 'lib\WpaiCore.ps1')
. (Join-Path $cli 'lib\WpaiBus.ps1')
. (Join-Path $cli 'lib\WpaiMusic.ps1')
. (Join-Path $cli 'lib\WpaiBridge.ps1')
. (Join-Path $cli 'lib\WpaiOvernight.ps1')
. (Join-Path $cli 'lib\WpaiResearch.ps1')
. (Join-Path $cli 'lib\WpaiBudgetLedger.ps1')

# Install / defaults
$r = Ensure-WpaiRuntime
Assert-True (Test-Path $r.Blackboard) 'BLACKBOARD exists'
Assert-True (Test-Path $r.ConfigPath) 'config exists'

# RMW generation bumps (do not clobber director_goal)
$g1 = [int](Get-WpaiBlackboard).generation
$goalKeep = [string](Get-WpaiBlackboard).director_goal
Invoke-WpaiBlackboardRmw -Mutator {
    param($bb)
    Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'test.gen_bump' -Actor 'bridge'
} | Out-Null
$g2 = [int](Get-WpaiBlackboard).generation
Assert-True ($g2 -gt $g1) "generation $g1 -> $g2"
# restore goal if anything mutated it
Invoke-WpaiBlackboardRmw -Mutator { param($bb) $bb['director_goal'] = $goalKeep } | Out-Null

# Concurrent-ish RMW (does not clobber director_goal)
$jobs = 1..5 | ForEach-Object {
    Start-Job -ScriptBlock {
        param($cliPath)
        . (Join-Path $cliPath 'lib\WpaiCore.ps1')
        Invoke-WpaiBlackboardRmw -Mutator {
            param($bb)
            Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'test.rmw' -Actor 'bridge' -Refs @{ pid = $PID }
        } | Out-Null
    } -ArgumentList $cli
}
$jobs | Wait-Job | Out-Null
$jobs | Remove-Job
$bb = Get-WpaiBlackboard
Assert-True ($bb.generation -ge $g2) 'post-concurrent generation ok'

# Cost model additive
$c = Get-WpaiCostEstimate -Rounds 1 -ExecutorInvocations 2
Assert-True ($c -eq 2.0) "cost 1 round + 2 exec = $c (expect 2.0)"

# Kill
Invoke-WpaiBlackboardRmw -Mutator { param($b) $b['kill_switch']['loops'] = $true } | Out-Null
Assert-True (Test-WpaiKillActive -Kind 'loops') 'loops kill active'
Invoke-WpaiBlackboardRmw -Mutator { param($b) $b['kill_switch']['loops'] = $false } | Out-Null

# Approval ticket lifecycle
$t = New-WpaiApprovalTicket -Kind 'generic' -Summary 'test ticket' -Division 'software'
Assert-True (Test-Path $t.Path) 'ticket file written'
$dec = Set-WpaiApprovalDecision -Id $t.Ticket.id -Decision 'approved'
Assert-True ($dec.status -eq 'approved') 'ticket approved'
try {
    Set-WpaiApprovalDecision -Id $t.Ticket.id -Decision 'rejected' | Out-Null
    Assert-True $false 'double decide should throw'
} catch {
    Assert-True $true 'double decide rejected'
}

# Janus job transform
$job = [pscustomobject]@{
    schema_version     = '1.0.0'
    kind               = 'janus_job'
    workload           = 'nodecore'
    validation_profile = 'forge-mod-v1'
    objective          = 'Unit test plan transform'
    files_in_scope     = @('src/Main.java')
    constraints        = @('no SuppressWarnings')
    acceptance_criteria = @('build clean')
    patch_mode         = 'manual'
}
$plan = ConvertTo-WpaiDelegationPlan -Job $job
Assert-True ($plan.parent.assignee -eq 'claude') 'parent assignee claude'
Assert-True ($plan.children[0].assignee -eq 'grok') 'child assignee grok'
Assert-True ($plan.children[0].patch_mode -eq 'manual') 'patch_mode manual'
Assert-True ($plan.children[0].task.workload -eq 'nodecore') 'child workload'
Assert-True ($plan.parent.spec.files_in_scope.Count -eq 0) 'parent files empty'

# Music package (Weaponized Mind) — check only; avoid ticket spam in CI
$music = Test-WpaiMusicPackage -ReleaseName 'Weaponized Mind'
Assert-True $music.pass 'Weaponized Mind package passes'
Assert-True (Test-Path $music.report_path) 'music report written'

# Overnight arm/disarm
$arm = Set-WpaiOvernightArm -ParentTaskIds @('task-test-parent') -MaxRounds 2
Assert-True ($arm.armed -eq $true) 'overnight armed'
$dry = Start-WpaiOvernight -DryRun
Assert-True ($dry.results.Count -ge 1) 'dry overnight results'
Assert-True (-not (Read-WpaiOvernightPlan).armed) 'disarmed after run'

# hf-bus truncate alignment
. (Join-Path $cli 'hf-bus.ps1')
$long = 'x' * 450
$m = New-HfBusMessage -Text $long -Type 'status' -From 'director' -To 'all'
Assert-True ($m.text.Length -le 400) "non-chat truncate len=$($m.text.Length)"

# Bus approve_request on ticket (unique summary avoids dedupe)
$beforeBus = 0
try { $beforeBus = (Get-Item (Get-WpaiBusPath)).Length } catch { $beforeBus = 0 }
$unique = 'bus notify test ' + [guid]::NewGuid().ToString('N').Substring(0, 8)
$t2 = New-WpaiApprovalTicket -Kind 'generic' -Summary $unique -AllowDuplicate
Assert-True (Test-Path $t2.Path) 'ticket2 written'
$afterBus = (Get-Item (Get-WpaiBusPath)).Length
Assert-True ($afterBus -gt $beforeBus) 'bus grew after approve_request'
# Dedupe: second identical music-style ticket returns same path
$d1 = New-WpaiApprovalTicket -Kind 'music_publish' -Summary 'dedupe-me' -Payload @{ release_name = 'DedupeTrack' }
$d2 = New-WpaiApprovalTicket -Kind 'music_publish' -Summary 'dedupe-me' -Payload @{ release_name = 'DedupeTrack' }
Assert-True ($d2.Deduped -eq $true) 'second ticket deduped'
Assert-True ($d1.Ticket.id -eq $d2.Ticket.id) 'dedupe reuses ticket id'

# Research gate refuses when dormant
$gate = Test-WpaiResearchAllowed
Assert-True (-not $gate.ok) 'research blocked while dormant'

# pending-ids: only pending ticket ids
$pendTicket = New-WpaiApprovalTicket -Kind 'generic' -Summary ('pending-ids ' + [guid]::NewGuid().ToString('N').Substring(0, 8)) -AllowDuplicate
$pendIds = @(Get-WpaiPendingApprovalIds)
Assert-True ($pendIds -contains $pendTicket.Ticket.id) 'pending-ids includes new ticket'
# CLI form: one id per line
$cli = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$cliOut = & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') approve pending-ids 2>$null
$cliLines = @($cliOut | Where-Object { $_ -and [string]$_ -match '^appr-' })
Assert-True ($cliLines -contains $pendTicket.Ticket.id) 'CLI pending-ids prints ticket id'

# purge-resolved: never deletes pending; deletes old approved/rejected/expired
$oldApproved = New-WpaiApprovalTicket -Kind 'generic' -Summary ('purge-old ' + [guid]::NewGuid().ToString('N').Substring(0, 8)) -AllowDuplicate
Set-WpaiApprovalDecision -Id $oldApproved.Ticket.id -Decision 'approved' | Out-Null
# Backdate decided_at so age exceeds cutoff
$oldPath = $oldApproved.Path
$oldObj = ConvertTo-WpaiHashtable (Read-WpaiJsonFile -Path $oldPath)
$oldObj['decided_at'] = ([DateTime]::UtcNow.AddDays(-30)).ToString('o')
$oldObj['requested_at'] = ([DateTime]::UtcNow.AddDays(-31)).ToString('o')
Write-WpaiJsonAtomic -Path $oldPath -Object $oldObj
$freshApproved = New-WpaiApprovalTicket -Kind 'generic' -Summary ('purge-fresh ' + [guid]::NewGuid().ToString('N').Substring(0, 8)) -AllowDuplicate
Set-WpaiApprovalDecision -Id $freshApproved.Ticket.id -Decision 'approved' | Out-Null
$pendingKeep = New-WpaiApprovalTicket -Kind 'generic' -Summary ('purge-pending ' + [guid]::NewGuid().ToString('N').Substring(0, 8)) -AllowDuplicate

$purgeWhatIf = Remove-WpaiResolvedApprovals -OlderThanDays 7 -WhatIf
Assert-True ($purgeWhatIf.deleted_count -ge 1) 'purge WhatIf finds old resolved'
Assert-True (Test-Path $oldPath) 'WhatIf does not delete file'

$purge = Remove-WpaiResolvedApprovals -OlderThanDays 7
Assert-True ($purge.deleted_count -ge 1) 'purge deleted at least one'
Assert-True (-not (Test-Path $oldPath)) 'old approved ticket file removed'
Assert-True (Test-Path $freshApproved.Path) 'fresh approved kept (< 7 days)'
Assert-True (Test-Path $pendingKeep.Path) 'pending never purged'
$stillPending = @(Get-WpaiPendingApprovalIds)
Assert-True ($stillPending -contains $pendingKeep.Ticket.id) 'pending-ids still lists keep ticket'

# Bus archive dry (may no-op if small)
$arch = Invoke-WpaiBusArchive -KeepLines 100000
Assert-True ($null -ne $arch) 'bus archive returns object'

# Budget ledger: double-entry dry charge + balance check (no paid APIs)
$chg = Add-WpaiBudgetCharge -Usd 0.01 -Memo 'unit-test dry charge' -DryRun
Assert-True ($chg.dry_run -eq $true) 'budget charge dry_run'
Assert-True ($chg.applied -eq $false) 'budget charge not applied on DryRun'
Assert-True ($chg.entry_id -like 'ble-*') 'budget charge entry_id'
Assert-True (Test-Path $chg.ledger_path) 'budget-ledger.jsonl exists'
$sum = Get-WpaiBudgetLedgerSummary -Tail 4
Assert-True ($sum.ledger_lines -ge 2) 'ledger has legs'
Assert-True ($null -ne $sum.day_cap_usd) 'ledger summary day cap'
$bal = Test-WpaiBudgetLedgerBalance
Assert-True ($bal.ok -eq $true) "ledger balanced ($($bal.reason) entries=$($bal.entries))"

Write-Host ""
if ($failed -gt 0) {
    Write-Host "FAILED: $failed assertion(s)" -ForegroundColor Red
    exit 1
}
Write-Host "ALL PASS" -ForegroundColor Green
exit 0
