<#
.SYNOPSIS
  Register or unregister a Task Scheduler task that runs wpai status at user logon.

.DESCRIPTION
  Creates task \WPAI\MorningStatus which launches:

    pwsh -NoProfile -File <StudioOps>\cli\wpai.ps1 status

  stdout/stderr redirect to:

    C:\WPAI\Workspace\.wpai\logs\morning-status.log

  Safe for HITL morning review: status only (no arm, no publish, no paid APIs).

.PARAMETER Unregister
  Remove the scheduled task if present.

.PARAMETER TaskName
  Task name under the WPAI folder. Default: MorningStatus.

.PARAMETER TaskPath
  Task Scheduler folder path. Default: \WPAI\

.PARAMETER WpaiPs1
  Path to wpai.ps1. Default: <repo>\cli\wpai.ps1 relative to this script.

.PARAMETER LogPath
  Log file path. Default: C:\WPAI\Workspace\.wpai\logs\morning-status.log

.EXAMPLE
  pwsh -NoProfile -File .\scripts\Register-WpaiMorningTask.ps1 -WhatIf

.EXAMPLE
  pwsh -NoProfile -File .\scripts\Register-WpaiMorningTask.ps1

.EXAMPLE
  pwsh -NoProfile -File .\scripts\Register-WpaiMorningTask.ps1 -Unregister
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [switch]$Unregister,
    [string]$TaskName = 'MorningStatus',
    [string]$TaskPath = '\WPAI\',
    [string]$WpaiPs1 = '',
    [string]$LogPath = 'C:\WPAI\Workspace\.wpai\logs\morning-status.log'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Normalize-TaskPath {
    param([string]$Path)
    $p = $Path.Trim()
    if (-not $p.StartsWith('\')) { $p = '\' + $p }
    if (-not $p.EndsWith('\')) { $p = $p + '\' }
    return $p
}

function Resolve-WpaiPs1Path {
    param([string]$Explicit)
    if ($Explicit) {
        if (-not (Test-Path -LiteralPath $Explicit)) {
            throw "wpai.ps1 not found: $Explicit"
        }
        return (Resolve-Path -LiteralPath $Explicit).Path
    }
    $here = Split-Path -Parent $PSCommandPath
    $candidate = Join-Path (Split-Path -Parent $here) 'cli\wpai.ps1'
    if (-not (Test-Path -LiteralPath $candidate)) {
        throw "wpai.ps1 not found at default path: $candidate (pass -WpaiPs1)"
    }
    return (Resolve-Path -LiteralPath $candidate).Path
}

function Find-PwshPath {
    $cmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) { return $cmd.Source }
    $fallbacks = @(
        (Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'PowerShell\7\pwsh.exe')
    )
    foreach ($p in $fallbacks) {
        if ($p -and (Test-Path -LiteralPath $p)) { return $p }
    }
    throw 'pwsh.exe not found on PATH. Install PowerShell 7+ before registering the task.'
}

function Get-WpaiScheduledTask {
    param([string]$Name, [string]$Path)
    $t = Get-ScheduledTask -TaskName $Name -TaskPath $Path -ErrorAction SilentlyContinue
    if ($t) { return $t }
    return Get-ScheduledTask -ErrorAction SilentlyContinue |
        Where-Object { $_.TaskName -eq $Name -and $_.TaskPath -eq $Path } |
        Select-Object -First 1
}

$taskPath = Normalize-TaskPath -Path $TaskPath
$fullId = "$taskPath$TaskName"

if ($Unregister) {
    $existing = Get-WpaiScheduledTask -Name $TaskName -Path $taskPath
    if (-not $existing) {
        Write-Host "Task not found: $fullId (nothing to unregister)" -ForegroundColor DarkYellow
        return
    }
    if ($PSCmdlet.ShouldProcess($fullId, 'Unregister scheduled task')) {
        Unregister-ScheduledTask -TaskName $existing.TaskName -TaskPath $existing.TaskPath -Confirm:$false
        Write-Host "Unregistered: $($existing.TaskPath)$($existing.TaskName)" -ForegroundColor Green
    }
    return
}

$wpaiPath = Resolve-WpaiPs1Path -Explicit $WpaiPs1
$pwshPath = Find-PwshPath
$logDir = Split-Path -Parent $LogPath
if ($logDir -and -not (Test-Path -LiteralPath $logDir)) {
    if ($PSCmdlet.ShouldProcess($logDir, 'Create log directory')) {
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    }
}

# cmd.exe so shell redirection works under Task Scheduler (paths may contain spaces).
# Pattern: cmd /c ""C:\path\pwsh.exe" -NoProfile -File "C:\path\wpai.ps1" status >> "C:\path\log" 2>&1"
$cmdArgument = '/d /c ""{0}" -NoProfile -File "{1}" status >> "{2}" 2>&1"' -f $pwshPath, $wpaiPath, $LogPath
$action = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument $cmdArgument
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 15) `
    -MultipleInstances IgnoreNew
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$description = "WPAI morning HITL: wpai status at logon. Log: $LogPath"

if ($PSCmdlet.ShouldProcess($fullId, "Register AtLogOn task (wpai status -> $LogPath)")) {
    $existing = Get-WpaiScheduledTask -Name $TaskName -Path $taskPath
    if ($existing) {
        Set-ScheduledTask -TaskName $TaskName -TaskPath $taskPath `
            -Action $action -Trigger $trigger -Settings $settings -Principal $principal |
            Out-Null
        # Description is not always applied by Set-ScheduledTask on all SKUs; re-register force if needed
        $null = Get-ScheduledTask -TaskName $TaskName -TaskPath $taskPath -ErrorAction SilentlyContinue
        Write-Host "Updated scheduled task: $fullId" -ForegroundColor Green
    } else {
        Register-ScheduledTask -TaskName $TaskName -TaskPath $taskPath `
            -Action $action -Trigger $trigger -Settings $settings -Principal $principal `
            -Description $description -Force | Out-Null
        Write-Host "Registered scheduled task: $fullId" -ForegroundColor Green
    }

    Write-Host "  Trigger : At logon ($env:USERNAME)" -ForegroundColor DarkGray
    Write-Host "  Action  : pwsh -NoProfile -File $wpaiPath status" -ForegroundColor DarkGray
    Write-Host "  Log     : $LogPath" -ForegroundColor DarkGray
    Write-Host "  Unregister: pwsh -NoProfile -File `"$PSCommandPath`" -Unregister" -ForegroundColor DarkGray
}
