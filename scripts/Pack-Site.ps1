<#
.SYNOPSIS
  Zip the static site for GoDaddy File Manager (or any static host) upload.
#>
[CmdletBinding()]
param(
    [string]$OutDir = 'C:\WPAI\Software\StudioOps\dist'
)

$ErrorActionPreference = 'Stop'
$site = 'C:\WPAI\Software\StudioOps\site'
if (-not (Test-Path -LiteralPath $site)) { throw "Missing site at $site" }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$zip = Join-Path $OutDir ("wpaistudio-net-site-{0}.zip" -f $stamp)

if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }

# Stage a clean tree (exclude backup/cache dirs) so index.html is at zip root
$stage = Join-Path $OutDir ('_stage-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $stage | Out-Null
try {
    Copy-Item -Path (Join-Path $site '*') -Destination $stage -Recurse -Force
    Get-ChildItem -LiteralPath $stage -Recurse -Directory -Force |
        Where-Object { $_.Name -like '_*' -or $_.Name -eq '.git' } |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -CompressionLevel Optimal
} finally {
    if (Test-Path -LiteralPath $stage) {
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "Packed -> $zip"
Write-Host "Upload zip contents to web root (index.html at domain root)."
return $zip
