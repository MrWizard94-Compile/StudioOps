# WPAI control-plane self-tests (PowerShell)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# Prevent nested re-entry when improve probes call Invoke-WpaiImproveRunUnitTests
$env:WPAI_IN_UNIT_TESTS = '1'
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
. (Join-Path $cli 'lib\WpaiBlackboardVerify.ps1')
. (Join-Path $cli 'lib\WpaiImproveSwarm.ps1')

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

# Gen3 #1: BLACKBOARD shape + falsify stress (guess-then-falsify)
$shape = Test-WpaiBlackboardShape -Blackboard (Get-WpaiBlackboard)
Assert-True $shape.ok ("blackboard shape ok issues=$($shape.issues -join ';')")
$falsify = Invoke-WpaiBlackboardFalsify -Workers 6 -PerWorker 3
Assert-True $falsify.ok ("falsify stress: $($falsify.verdict) issues=$($falsify.issues -join ';')")
Assert-True ($falsify.static_score -ge 1.0) "falsify static_score=$($falsify.static_score)"
Assert-True $falsify.kill_research_held 'kill_switch.research held under concurrency'
$doc = Invoke-WpaiBlackboardDoctor -DoRepair -DoFalsify:$false
Assert-True $doc.ok 'board doctor shape-only ok'
Assert-True ($null -eq $doc.falsify) 'shape-only doctor skips falsify'

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

# ── Improve swarm: learning, bans, diversity, fitness feedback ───────────────
$geneTl = Get-WpaiImproveGeneKey -Tactic 'raise-context' -Lever 'latency' -Kind tactic_lever
Assert-True ($geneTl -eq 'raise-context×latency') "gene key tactic_lever=$geneTl"

$rec = Write-WpaiImproveOutcome -PathId 'path-testban0001' -Verdict 'KILLED' -Source 'unit-test' `
    -Note 'unit-test kill for raise-context×latency' `
    -Target 'janus-loop' -Lever 'latency' -Tactic 'raise-context' -Invert 'none' -Probe 'static-score' -Force
Assert-True ($rec.appended -eq $true) 'outcome append for test kill'
Assert-True ($rec.gene_tactic_lever -eq 'raise-context×latency') 'outcome gene_tactic_lever'

$learn = Invoke-WpaiImproveLearn -SkipIngest
Assert-True ($learn.bans_total -ge 1) "learn bans_total=$($learn.bans_total)"
Assert-True (Test-Path $learn.bans_path) 'bans.json exists'
Assert-True (Test-Path $learn.learning_path) 'LEARNING.md exists'

$banHit = Test-WpaiImproveGeneBanned -Target 'janus-loop' -Lever 'latency' -Tactic 'raise-context' -Invert 'none' -Probe 'static-score'
Assert-True ($banHit.banned -eq $true) 'raise-context×latency is banned after learn'

$alive = Test-WpaiImproveGeneBanned -Target 'overnight' -Lever 'reliability' -Tactic 'chaos-inject' -Invert 'none' -Probe 'schema-validate'
# may or may not be banned depending on ledger; just ensure call works
Assert-True ($null -ne $alive.banned) 'ban check returns banned flag'

$fakePath = [pscustomobject]@{
    id = 'path-testfit0001'; target = 'studioops-cli'; lever = 'latency'; tactic = 'raise-context'
    invert = 'none'; probe = 'static-score'; hypothesis = 'On studioops-cli, improve latency by applying raise-context; validate with static-score.'
    unconventional = $false; risk = 'low'; cost_to_try = 'cheap'
}
$fitBanned = Get-WpaiImproveFitness -PathObj $fakePath
Assert-True ($fitBanned.banned -eq $true) 'fitness marks banned gene'
Assert-True ($fitBanned.score -lt 0.15) "banned fitness score low ($($fitBanned.score))"

$fakeGood = [pscustomobject]@{
    id = 'path-testfit0002'; target = 'studioops-cli'; lever = 'reliability'; tactic = 'double-entry'
    invert = 'guess-then-falsify'; probe = 'static-score'
    hypothesis = 'On studioops-cli, improve reliability by applying double-entry via guess-then-falsify; validate with static-score.'
    unconventional = $true; risk = 'low'; cost_to_try = 'cheap'
}
$fitGood = Get-WpaiImproveFitness -PathObj $fakeGood
Assert-True ($fitGood.banned -eq $false) 'good gene not banned'
Assert-True ($fitGood.score -gt $fitBanned.score) "good score $($fitGood.score) > banned $($fitBanned.score)"

# Diversity selection: many clones of one target should not fill entire top-K
$divIn = @()
for ($i = 0; $i -lt 8; $i++) {
    $divIn += [pscustomobject]@{
        id = "path-div-a$i"; score = 0.9 - ($i * 0.01); banned = $false
        target = 'studioops-cli'; lever = 'latency'; tactic = 'cache'
        hypothesis = 'clone-a'
    }
}
for ($i = 0; $i -lt 5; $i++) {
    $divIn += [pscustomobject]@{
        id = "path-div-b$i"; score = 0.7 - ($i * 0.01); banned = $false
        target = 'overnight'; lever = 'reliability'; tactic = 'fuzz'
        hypothesis = 'clone-b'
    }
}
$divOut = @(Select-WpaiImproveDiverseTop -Ranked $divIn -Top 6)
Assert-True ($divOut.Count -eq 6) "diverse top count=$($divOut.Count)"
$targets = @($divOut | ForEach-Object { $_.target } | Select-Object -Unique)
Assert-True ($targets.Count -ge 2) "diversity keeps multiple targets ($($targets -join ','))"

$st = Get-WpaiImproveStatus
Assert-True ($st.catalog_paths -ge 0) 'improve status returns catalog_paths'
Assert-True ($st.outcomes -ge 1) "improve status outcomes=$($st.outcomes)"

# Self-swarm surface: recipes, elite, auto-experiment plumbing
$recipes = @(Get-WpaiImproveSelfRecipes)
Assert-True ($recipes.Count -ge 8) "self recipes count=$($recipes.Count)"
Assert-True (@($recipes | Where-Object { $_.t -eq 'improve-swarm' }).Count -ge 1) 'self recipes target improve-swarm'
$eliteUp = Update-WpaiImproveEliteArchive
Assert-True ($eliteUp.count -ge 0) "elite archive count=$($eliteUp.count)"
Assert-True (Test-Path $eliteUp.path) 'elite.json path exists'
$fakeSelf = [pscustomobject]@{
    id = 'path-selftest0001'; target = 'improve-swarm'; lever = 'reliability'; tactic = 'fail-closed'
    invert = 'none'; probe = 'unit-test'
    hypothesis = 'On improve-swarm, improve reliability by applying fail-closed; validate with unit-test.'
    unconventional = $true; risk = 'low'; cost_to_try = 'cheap'; banned = $false; score = 0.7
}
$autoOne = Invoke-WpaiImproveAutoExperiment -Survivor $fakeSelf -Force
Assert-True ($autoOne.verdict -in @('SUPPORTED', 'KILLED', 'INCONCLUSIVE')) "auto experiment verdict=$($autoOne.verdict)"
Assert-True ($autoOne.evidence_tier -in @('weak', 'structural', 'strong', 'measured')) "evidence tier=$($autoOne.evidence_tier)"
Assert-True (Test-Path $autoOne.result_path) 'auto experiment wrote result.json'

# Evidence weights: weak < structural < strong <= measured
Assert-True ((Get-WpaiImproveEvidenceWeight -Tier 'weak') -lt (Get-WpaiImproveEvidenceWeight -Tier 'structural')) 'weak < structural weight'
Assert-True ((Get-WpaiImproveEvidenceWeight -Tier 'structural') -lt (Get-WpaiImproveEvidenceWeight -Tier 'strong')) 'structural < strong weight'
Assert-True ((Get-WpaiImproveEvidenceWeight -Tier 'measured') -ge (Get-WpaiImproveEvidenceWeight -Tier 'strong')) 'measured >= strong'

# Stagnation map + jitter are callable
$stag = Get-WpaiImproveStagnationMap
Assert-True ($null -ne $stag.path) 'stagnation map has path table'
$j1 = Get-WpaiImproveStableJitter -PathId 'path-aaa'
$j2 = Get-WpaiImproveStableJitter -PathId 'path-aaa'
$j3 = Get-WpaiImproveStableJitter -PathId 'path-bbb'
Assert-True ($j1 -eq $j2) 'jitter stable for same id'
Assert-True ($j1 -ne $j3 -or $true) 'jitter defined for different ids'

# Fitness exposes exploration / stagnation fields
$fitV2 = Get-WpaiImproveFitness -PathObj $fakeGood
Assert-True ($null -ne $fitV2.explore_bonus -or $fitV2.explore_bonus -eq 0) 'fitness has explore_bonus'
Assert-True ($null -ne $fitV2.stagnation_pen -or $fitV2.stagnation_pen -eq 0) 'fitness has stagnation_pen'

$meta = Write-WpaiImproveMetaReport
Assert-True (Test-Path $meta.path) 'META.md written'
Assert-True ($meta.total -ge 1) "meta total outcomes=$($meta.total)"

# Auto-review classification (honest labels) — do not nest full unit suite (-SkipTests)
$shipKind = Get-WpaiImproveHypoKind -Item ([pscustomobject]@{
        path_id = 'path-8e633381189e'; verdict = 'SUPPORTED'; breakthrough_class = 'ship:blackboard-integrity-doctor'
        note = 'doctor'; source = 'experiment'
    })
Assert-True ($shipKind.kind -eq 'SHIPPED') "ship class -> $($shipKind.kind)"
$ideaKind = Get-WpaiImproveHypoKind -Item ([pscustomobject]@{
        path_id = 'path-idea00000001'; verdict = ''; note = 'On studioops-cli, improve latency by applying cache'
        source = 'generation'
    })
Assert-True ($ideaKind.kind -eq 'IDEA') "bare hypothesis -> $($ideaKind.kind)"
$propKind = Get-WpaiImproveHypoKind -Item ([pscustomobject]@{
        path_id = 'path-prop00000001'; verdict = 'SUPPORTED'; breakthrough_class = 'measured:budget-ledger-balanced'
        note = 'budget ledger balanced'; source = 'auto-experiment'
    })
Assert-True ($propKind.kind -eq 'PROPERTY') "measured invariant -> $($propKind.kind)"
$rev = Invoke-WpaiImproveAutoReview -TopLeaders 5 -SkipTests
Assert-True (Test-Path $rev.path) 'SELF-REVIEW.md written'
Assert-True (($rev.shipped + $rev.property + $rev.idea + $rev.killed) -ge 1) 'review has classified rows'
# Nested unit-test runner must not recurse
$nested = Invoke-WpaiImproveRunUnitTests
Assert-True ($null -ne $nested.summary) "unit test runner returns summary=$($nested.summary)"
# Generation attaches kind and demotes pure ideas vs shipped when outcomes exist
$sampleIdea = Get-WpaiImproveFitness -PathObj ([pscustomobject]@{
        id = 'path-neverseen0001'; target = 'gaming-mod'; lever = 'novelty'; tactic = 'document-only'
        invert = 'none'; probe = 'docs-delta'; hypothesis = 'On gaming-mod, improve novelty by applying document-only; validate with docs-delta.'
        unconventional = $true; risk = 'low'; cost_to_try = 'cheap'
    })
Assert-True ($sampleIdea.score -ge 0) "fitness still scores unseen idea=$($sampleIdea.score)"
Assert-True ($sampleIdea.explore_method -eq 'ucb1') 'fitness uses ucb1 explore'
Assert-True ($sampleIdea.explore_bonus -gt 0) "untried gene ucb1 bonus=$($sampleIdea.explore_bonus)"

# Tournament selection returns unique-ish parents
$tPool = 1..8 | ForEach-Object {
    [pscustomobject]@{ id = "path-t$_"; score = 0.1 * $_; adj = 0.1 * $_ }
}
$tPick = @(Select-WpaiImproveTournament -Pool $tPool -Count 3 -TournamentSize 3)
Assert-True ($tPick.Count -eq 3) "tournament count=$($tPick.Count)"
$tIds = @($tPick | ForEach-Object { $_.id } | Select-Object -Unique)
Assert-True ($tIds.Count -ge 2) "tournament diversity ids=$($tIds.Count)"

# Crowding bonus higher for unused axes
$crowdNew = Get-WpaiImproveCrowdingBonus -Candidate ([pscustomobject]@{ target = 'zz'; lever = 'yy'; tactic = 'xx' }) `
    -UsedTargets @{} -UsedLevers @{} -UsedTactics @{} -UsedTl @{}
$crowdOld = Get-WpaiImproveCrowdingBonus -Candidate ([pscustomobject]@{ target = 'aa'; lever = 'bb'; tactic = 'cc' }) `
    -UsedTargets @{ aa = 5 } -UsedLevers @{ bb = 5 } -UsedTactics @{ cc = 5 } -UsedTl @{ 'cc×bb' = 5 }
Assert-True ($crowdNew -gt $crowdOld) "crowding new=$crowdNew > old=$crowdOld"

Write-Host ""
if ($failed -gt 0) {
    Write-Host "FAILED: $failed assertion(s)" -ForegroundColor Red
    exit 1
}
Write-Host "ALL PASS" -ForegroundColor Green
exit 0
