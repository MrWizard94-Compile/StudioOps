<#
.SYNOPSIS
  Register or unregister an optional 03:00 local Task Scheduler task for wpai overnight start.

.DESCRIPTION
  Creates task \WPAI\OvernightStart which daily at 03:00 local time runs:

    pwsh -NoProfile -File <StudioOps>\cli\wpai.ps1 overnight start

  stdout/stderr redirect to:

    C:\WPAI\Workspace\.wpai\logs\overnight-scheduled.log

  *** ARM IS REQUIRED ***
  Registering this task does NOT arm overnight work. Without a prior:

    wpai overnight arm -ParentTaskIds <id> [-MaxRounds N]

  the scheduled start will fail closed (overnight not armed / expired).
  Director must arm intentionally; arm expires; kill switches still apply.
  No unsupervised publish. Mid-loop cost model charges every round when armed.

.PARAMETER Unregister
  Remove the scheduled task if present.

.PARAMETER TaskName
  Task name under the WPAI folder. Default: OvernightStart.

.PARAMETER TaskPath
  Task Scheduler folder path. Default: \WPAI\

.PARAMETER Time
  Daily local start time. Default: 03:00.

.PARAMETER WpaiPs1
  Path to wpai.ps1. Default: <repo>\cli\wpai.ps1 relative to this script.

.PARAMETER LogPath
  Log file path. Default: C:\WPAI\Workspace\.wpai\logs\overnight-scheduled.log

.EXAMPLE
  pwsh -NoProfile -File .\scripts\Register-WpaiOvernightTask.ps1 -WhatIf

.EXAMPLE
  # After Director has armed overnight for the night:
  pwsh -NoProfile -File .\scripts\Register-WpaiOvernightTask.ps1

.EXAMPLE
  pwsh -NoProfile -File .\scripts\Register-WpaiOvernightTask.ps1 -Unregister
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [switch]$Unregister,
    [string]$TaskName = 'OvernightStart',
    [string]$TaskPath = '\WPAI\',
    [string]$Time = '03:00',
    [string]$WpaiPs1 = '',
    [string]$LogPath = 'C:\WPAI\Workspace\.wpai\logs\overnight-scheduled.log'
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

function Parse-LocalDailyTime {
    param([string]$Value)
    $formats = @('H:mm', 'HH:mm', 'h:mm tt', 'hh:mm tt')
    foreach ($fmt in $formats) {
        try {
            return [DateTime]::ParseExact(
                $Value.Trim(),
                $fmt,
                [System.Globalization.CultureInfo]::InvariantCulture
            )
        } catch {
            # try next
        }
    }
    try {
        return [DateTime]::Parse($Value, [System.Globalization.CultureInfo]::CurrentCulture)
    } catch {
        throw "Invalid -Time '$Value'. Use local time like 03:00."
    }
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
$startTime = Parse-LocalDailyTime -Value $Time

$logDir = Split-Path -Parent $LogPath
if ($logDir -and -not (Test-Path -LiteralPath $logDir)) {
    if ($PSCmdlet.ShouldProcess($logDir, 'Create log directory')) {
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    }
}

Write-Host ''
Write-Host 'NOTE: Overnight ARM IS REQUIRED for this task to do work.' -ForegroundColor Yellow
Write-Host '  Registering only schedules: wpai overnight start' -ForegroundColor Yellow
Write-Host '  Without a valid arm (parent task ids + unexpired plan), start fails closed.' -ForegroundColor Yellow
Write-Host '  Arm example:' -ForegroundColor Yellow
Write-Host '    pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 overnight arm -ParentTaskIds task-XXXX -MaxRounds 5' -ForegroundColor DarkYellow
Write-Host '  Disarm / kill:' -ForegroundColor Yellow
Write-Host '    wpai overnight disarm' -ForegroundColor DarkYellow
Write-Host '    wpai kill set loops true' -ForegroundColor DarkYellow
Write-Host ''

# Append each night so history is preserved; rotate manually if large.
$cmdArgument = '/d /c ""{0}" -NoProfile -File "{1}" overnight start >> "{2}" 2>&1"' -f $pwshPath, $wpaiPath, $LogPath
$action = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument $cmdArgument
$trigger = New-ScheduledTaskTrigger -Daily -At $startTime
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 8) `
    -MultipleInstances IgnoreNew
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$description = "WPAI overnight start at local $Time. ARM REQUIRED. Log: $LogPath"

if ($PSCmdlet.ShouldProcess($fullId, "Register daily $Time task (wpai overnight start -> $LogPath)")) {
    $existing = Get-WpaiScheduledTask -Name $TaskName -Path $taskPath
    if ($existing) {
        Set-ScheduledTask -TaskName $TaskName -TaskPath $taskPath `
            -Action $action -Trigger $trigger -Settings $settings -Principal $principal |
            Out-Null
        Write-Host "Updated scheduled task: $fullId" -ForegroundColor Green
    } else {
        Register-ScheduledTask -TaskName $TaskName -TaskPath $taskPath `
            -Action $action -Trigger $trigger -Settings $settings -Principal $principal `
            -Description $description -Force | Out-Null
        Write-Host "Registered scheduled task: $fullId" -ForegroundColor Green
    }

    Write-Host "  Trigger : Daily at $Time local ($env:USERNAME)" -ForegroundColor DarkGray
    Write-Host "  Action  : pwsh -NoProfile -File $wpaiPath overnight start" -ForegroundColor DarkGray
    Write-Host "  Log     : $LogPath" -ForegroundColor DarkGray
    Write-Host "  Arm     : REQUIRED before the run (fail-closed if missing/expired)" -ForegroundColor DarkGray
    Write-Host "  Unregister: pwsh -NoProfile -File `"$PSCommandPath`" -Unregister" -ForegroundColor DarkGray
}
