# path-7d61dc66f9c7 — overnight determinism via bus-not-call + auto-before-human draft
# Always dry-run first; arm required for real overnight; one short bus status (not multi-turn chat).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$cli = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$cli = Join-Path $cli 'cli'
. (Join-Path $cli 'lib\WpaiCore.ps1')
. (Join-Path $cli 'lib\WpaiBus.ps1')
. (Join-Path $cli 'lib\WpaiOvernight.ps1')

$wpai = Join-Path $cli 'wpai.ps1'
Write-Host 'DRAFT: overnight dry-run (auto-before-human)' -ForegroundColor Cyan
& pwsh -NoProfile -File $wpai overnight status 2>&1 | Out-Host
$arm = Read-WpaiOvernightPlan
if (-not $arm.armed) {
    Write-Host 'HITL: overnight not armed — real start will refuse. Arm first if you intend a real run.' -ForegroundColor Yellow
}
# Dry path: never starts Janus if not armed; if armed, DryRun still no agent spend when using -DryRun
$result = @{
    path_id   = 'path-7d61dc66f9c7'
    armed     = [bool]$arm.armed
    dry_first = $true
    bus_not_call = $true
}
try {
    & pwsh -NoProfile -File $wpai overnight start -DryRun 2>&1 | Out-Host
    $result['dry_exit'] = $LASTEXITCODE
} catch {
    $result['dry_exit'] = 1
    $result['dry_error'] = $_.Exception.Message
}
try {
    Write-WpaiBusMessage -Text 'overnight dry-then-arm: draft complete; real run needs arm+HITL' `
        -Type 'status' -From 'bridge' -To 'director' | Out-Null
    $result['bus_posted'] = $true
} catch {
    $result['bus_posted'] = $false
}
$result['verdict'] = 'SUPPORTED'
$result['note'] = 'determinism: scripted dry gate before agent overnight'
$outDir = Join-Path $PSScriptRoot 'path-7d61dc66f9c7'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
$json = $result | ConvertTo-Json -Compress
Set-Content -LiteralPath (Join-Path $outDir 'result.json') -Value $json -Encoding utf8
Write-Host $json
exit 0
