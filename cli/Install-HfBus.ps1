<#
.SYNOPSIS
  Install hf-bus / hf-say into the current user's PowerShell profile.
#>
[CmdletBinding()]
param(
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$moduleLine = '. "C:\WPAI\Software\StudioOps\cli\hf-bus.ps1"'
$marker = '# StudioOps hf-bus (WPAI)'

$profilePath = $PROFILE.CurrentUserAllHosts
if (-not $profilePath) { $profilePath = $PROFILE }

$dir = Split-Path -Parent $profilePath
if (-not (Test-Path -LiteralPath $dir)) {
    if ($WhatIf) {
        Write-Host "Would create profile directory: $dir"
    } else {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

$existing = ''
if (Test-Path -LiteralPath $profilePath) {
    $existing = Get-Content -LiteralPath $profilePath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $existing) { $existing = '' }
}

if ($existing -match [regex]::Escape($marker)) {
    Write-Host "Already installed in $profilePath"
    return
}

$block = @"

$marker
if (Test-Path -LiteralPath 'C:\WPAI\Software\StudioOps\cli\hf-bus.ps1') {
    $moduleLine
}

"@

if ($WhatIf) {
    Write-Host "Would append to $profilePath :"
    Write-Host $block
    return
}

Add-Content -LiteralPath $profilePath -Value $block -Encoding utf8
Write-Host "Installed. Restart pwsh or run: $moduleLine"
Write-Host "Profile: $profilePath"
