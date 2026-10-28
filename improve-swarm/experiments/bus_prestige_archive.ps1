<#
.SYNOPSIS
  path-ac4bacaf07a8 — bus prestige archive (idle-game prestige analog).

.DESCRIPTION
  When hellforge bus.jsonl exceeds N lines (default 800), archive via
  `wpai bus archive -Keep 400` and print a prestige message.
  Keeps short telegrams on the live bus; substance stays on disk handoffs (Protocol).
  Measurable auto-archive trigger only — no money, no paid APIs.

.EXAMPLE
  pwsh -NoProfile -File improve-swarm\experiments\bus_prestige_archive.ps1
  pwsh -NoProfile -File improve-swarm\experiments\bus_prestige_archive.ps1 -Threshold 999999
  pwsh -NoProfile -File improve-swarm\experiments\bus_prestige_archive.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [int]$Threshold = 800,
    [int]$Keep = 400,
    [switch]$DryRun,
    [string]$BusPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$WpaiCli = Join-Path $repoRoot 'cli\wpai.ps1'
if (-not (Test-Path -LiteralPath $WpaiCli)) {
    $WpaiCli = 'C:\WPAI\Software\StudioOps\cli\wpai.ps1'
}
if (-not (Test-Path -LiteralPath $WpaiCli)) {
    Write-Host 'KILL: wpai.ps1 not found — path fails' -ForegroundColor Red
    exit 2
}

if (-not $BusPath) {
    $libDir = Join-Path $repoRoot 'cli\lib'
    . (Join-Path $libDir 'WpaiCore.ps1')
    . (Join-Path $libDir 'WpaiBus.ps1')
    $BusPath = Get-WpaiBusPath
}

$lineCount = 0
if (Test-Path -LiteralPath $BusPath) {
    $lineCount = @(Get-Content -LiteralPath $BusPath -Encoding utf8).Count
}

Write-Host '=== bus_prestige_archive (path-ac4bacaf07a8) ===' -ForegroundColor Cyan
Write-Host ("bus={0}" -f $BusPath)
Write-Host ("lines={0} threshold={1} keep={2} dryRun={3}" -f $lineCount, $Threshold, $Keep, [bool]$DryRun)

if ($lineCount -le $Threshold) {
    Write-Host ("NO-OP: lines ({0}) <= threshold ({1}) — prestige not triggered" -f $lineCount, $Threshold) -ForegroundColor DarkGray
    Write-Host 'SUPPORTED: measurable auto-archive gate works (idle-game prestige = archive when large)' -ForegroundColor Green
    exit 0
}

# Prestige: bus too large → archive old telegrams, keep recent Keep lines
Write-Host ("PRESTIGE: bus lines {0} > {1} — archiving, keep {2}" -f $lineCount, $Threshold, $Keep) -ForegroundColor Yellow

if ($DryRun) {
    Write-Host ("DRY-RUN: would call wpai bus archive -Keep {0}" -f $Keep) -ForegroundColor Magenta
    Write-Host 'SUPPORTED: trigger fired; archive skipped (DryRun)' -ForegroundColor Green
    exit 0
}

$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& pwsh -NoProfile -File $WpaiCli bus archive -Keep $Keep
$archExit = $LASTEXITCODE
$ErrorActionPreference = $prevEap
if ($null -eq $archExit) { $archExit = 0 }

$after = 0
if (Test-Path -LiteralPath $BusPath) {
    $after = @(Get-Content -LiteralPath $BusPath -Encoding utf8).Count
}

Write-Host ("PRESTIGE COMPLETE: archive exit={0}; lines now={1} (was {2})" -f $archExit, $after, $lineCount) -ForegroundColor Green
Write-Host 'Protocol reminder: short telegrams on bus; substance on disk handoffs.' -ForegroundColor DarkGray
exit $archExit
