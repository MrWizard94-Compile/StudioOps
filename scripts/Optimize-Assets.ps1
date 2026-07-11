<#
.SYNOPSIS
  Re-encode site assets for faster loads (keeps filenames HTML already references).
  Executor lane: site/assets only. Does not touch HTML/CSS.
#>
[CmdletBinding()]
param(
    [int]$JpegQuality = 82,
    [int]$MaxEdge = 1600
)

$ErrorActionPreference = 'Stop'
$py = 'C:\WPAI\Software\StudioOps\scripts\optimize_assets.py'
if (-not (Test-Path -LiteralPath $py)) { throw "Missing $py" }
& python $py $MaxEdge $JpegQuality
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Asset optimize complete." -ForegroundColor Green
