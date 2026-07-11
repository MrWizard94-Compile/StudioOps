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
. (Join-Path $cli 'lib\WpaiMusic.ps1')
. (Join-Path $cli 'lib\WpaiBridge.ps1')
. (Join-Path $cli 'lib\WpaiOvernight.ps1')

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

Write-Host ""
if ($failed -gt 0) {
    Write-Host "FAILED: $failed assertion(s)" -ForegroundColor Red
    exit 1
}
Write-Host "ALL PASS" -ForegroundColor Green
exit 0
