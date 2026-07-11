# Bootstrap C:\WPAI\Workspace\.wpai runtime (not a git PR target).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $here 'wpai.ps1') -Command install @args
$wpai = 'C:\WPAI\Workspace\.wpai'
Write-Host ""
Write-Host "Optional: add to profile:" -ForegroundColor DarkYellow
Write-Host '  function wpai { pwsh -NoProfile -File "C:\WPAI\Software\StudioOps\cli\wpai.ps1" @args }'
Write-Host "HellForge bus CLI still: . $here\hf-bus.ps1"
Write-Host "Runtime root: $wpai"
