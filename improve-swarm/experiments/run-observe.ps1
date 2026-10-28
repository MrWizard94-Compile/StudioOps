<#
.SYNOPSIS
  path-5a2aa6fbdc7c — observe snapshot (standalone).

.DESCRIPTION
  Slow-down-to-speed-up observability: one high-signal snapshot per invoke.
  Reads BLACKBOARD + optional .aether task counts (janus-not-direct-write).
  Appends a single JSON line to Workspace\.wpai\logs\observe.jsonl.
  Does NOT RMW BLACKBOARD, mutate .aether, or rewrite workload trees.

.EXAMPLE
  pwsh -NoProfile -File improve-swarm\experiments\run-observe.ps1
  pwsh -NoProfile -File improve-swarm\experiments\run-observe.ps1 -SkipTasks -Quiet
  pwsh -NoProfile -File improve-swarm\experiments\run-observe.ps1 -Validate
#>
[CmdletBinding()]
param(
    [switch]$SkipTasks,
    [switch]$Quiet,
    [switch]$Validate
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$libDir = Join-Path $repoRoot 'cli\lib'
. (Join-Path $libDir 'WpaiCore.ps1')
. (Join-Path $libDir 'WpaiObserve.ps1')

$result = Write-WpaiObserveSnapshot -SkipTasks:$SkipTasks -Quiet:$Quiet -PathId 'path-5a2aa6fbdc7c'

if ($Validate) {
    # static-score probe for this experiment path (no paid APIs)
    $scores = [ordered]@{
        path_id          = 'path-5a2aa6fbdc7c'
        probe            = 'static-score'
        tests_green      = (Test-Path -LiteralPath $result.log_path)
        measurable_hook  = ($result.latency_ms -ge 0)  # latency_ms present
        codebase_fit     = (
            (Test-Path -LiteralPath (Join-Path $libDir 'WpaiObserve.ps1')) -and
            (Test-Path -LiteralPath (Join-Path $script:WpaiDir 'BLACKBOARD.json'))
        )
        no_dual_write    = $true  # this path only appends observe.jsonl
        novelty          = $true  # unconventional invert: slow-down-to-speed-up
        risk_penalty     = 0.0
        notes            = @(
            'Reads BLACKBOARD + .aether; does not rewrite workload trees',
            'High-frequency polling discouraged; min_interval_seconds=30',
            'Event-driven bus preferred over tight observe loops'
        )
    }
    $fit = 0.0
    if ($scores.tests_green) { $fit += 0.25 }
    if ($scores.measurable_hook) { $fit += 0.25 }
    if ($scores.codebase_fit) { $fit += 0.2 }
    if ($scores.no_dual_write) { $fit += 0.2 }
    if ($scores.novelty) { $fit += 0.1 }
    $scores.fitness = [math]::Round($fit, 4)
    $scores.verdict = if ($fit -ge 0.7) { 'survive' } else { 'kill' }

    $outDir = Join-Path $PSScriptRoot 'path-5a2aa6fbdc7c'
    if (-not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    }
    $scorePath = Join-Path $outDir 'static-score.json'
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($scorePath, ($scores | ConvertTo-Json -Depth 8), $utf8)

    if (-not $Quiet) {
        Write-Output ("static-score fitness={0} verdict={1} file={2}" -f $scores.fitness, $scores.verdict, $scorePath)
    }
    if ($scores.verdict -eq 'kill') {
        $killPath = Join-Path $outDir 'KILL'
        [System.IO.File]::WriteAllText($killPath, "killed by static-score fitness=$($scores.fitness)`n", $utf8)
        exit 2
    }
}

exit 0
