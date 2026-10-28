# path-9fef7d2b6aa8 — research-genome determinism via idle-game-ops + auto-before-human-for-drafts
# Always dry-run first; never launch forever (META_GENERATIONS=0 blocked). No money / no long engine runs.
# Prestige rule: archive stuck genome before reset (idle-game prestige analog).
param(
    [int]$MetaGenerations = 3
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$WpaiCli = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'cli\wpai.ps1'
if (-not (Test-Path -LiteralPath $WpaiCli)) {
    $WpaiCli = 'C:\WPAI\Software\StudioOps\cli\wpai.ps1'
}
if (-not (Test-Path -LiteralPath $WpaiCli)) {
    Write-Host 'KILL: wpai.ps1 not found — path fails' -ForegroundColor Red
    exit 2
}

# Block forever-mode (META_GENERATIONS=0) — determinism + funding gate
if ($MetaGenerations -eq 0) {
    Write-Host 'BLOCKED: META_GENERATIONS=0 (forever) denied by research_dry_then_ask' -ForegroundColor Yellow
    Write-Host 'Prestige: archive genome when stuck; reset stuck loop only after archive.' -ForegroundColor DarkGray
    Write-Host 'HITL: approve research_enable ticket before real run' -ForegroundColor Cyan
    exit 1
}

Write-Host '=== research_dry_then_ask (auto draft before human) ===' -ForegroundColor Cyan
Write-Host ("MetaGenerations={0} (0 blocked)" -f $MetaGenerations)
Write-Host 'Prestige: archive genome when stuck; reset stuck loop only after archive.' -ForegroundColor DarkGray

# Auto-before-human: always dry-run first (no engine start, no money)
Write-Host 'STEP 1/2: wpai research run -DryRun' -ForegroundColor Green
$dryArgs = @(
    '-NoProfile', '-File', $WpaiCli,
    'research', 'run',
    '-DryRun',
    '-MaxRounds', [string]$MetaGenerations
)
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& pwsh @dryArgs
$dryExit = $LASTEXITCODE
$ErrorActionPreference = $prevEap

if ($null -eq $dryExit) { $dryExit = 0 }

Write-Host ("DryRun exit={0}" -f $dryExit)
Write-Host 'STEP 2/2: human gate (no real run from this script)' -ForegroundColor Yellow
Write-Host 'HITL: approve research_enable ticket before real run' -ForegroundColor Cyan
Write-Host 'Next: wpai research request  then  wpai approve decide <id> approved  then  wpai research run -MetaGenerations N' -ForegroundColor DarkGray

# Success = dry path exercised + forever blocked + HITL message printed (no real engine)
exit 0
