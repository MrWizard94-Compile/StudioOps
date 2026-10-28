<#
.SYNOPSIS
  Register or unregister a current-user scheduled task for WPAI overnight start.

.DESCRIPTION
  Creates a Windows Task Scheduler task under the current user (no admin required)
  that runs:

    pwsh -NoProfile -File <StudioOps>\cli\wpai.ps1 overnight start

  IMPORTANT: Overnight only executes when armed. Before a scheduled run can do work,
  arm parents once (or re-arm after each start, which disarms):

    pwsh -File ...\wpai.ps1 overnight arm -ParentTaskIds <id>[,id2] [-MaxRounds 10]

  If not armed, overnight start fails closed (no spend, no Janus loop).
  This installer performs no network I/O and no paid API calls.

.PARAMETER Unregister
  Remove the scheduled task if present.

.PARAMETER WhatIf
  Print actions without registering or removing the task.

.PARAMETER Daily
  Register a daily trigger (default: on). Use -Daily:$false to skip.

.PARAMETER AtLogOn
  Also (or only) trigger at current-user logon.

.PARAMETER At
  Daily run time (local). Default 02:30.

.PARAMETER TaskName
  Scheduled task name. Default: WPAI-StudioOps-Overnight

.EXAMPLE
  pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\Install-ScheduledOvernight.ps1 -WhatIf
  pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\Install-ScheduledOvernight.ps1 -Daily -At '03:00'
  pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\Install-ScheduledOvernight.ps1 -AtLogOn
  pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\Install-ScheduledOvernight.ps1 -Unregister
#>
[CmdletBinding()]
param(
    [switch]$Unregister,
    [switch]$WhatIf,
    [bool]$Daily = $true,
    [switch]$AtLogOn,
    [string]$At = '02:30',
    [string]$TaskName = 'WPAI-StudioOps-Overnight'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$wpaiPs1 = Join-Path $here 'wpai.ps1'
if (-not (Test-Path -LiteralPath $wpaiPs1)) {
    throw "wpai.ps1 not found next to installer: $wpaiPs1"
}

$pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $pwshCmd) { $pwshCmd = Get-Command powershell -ErrorAction SilentlyContinue }
if (-not $pwshCmd) { throw 'Neither pwsh nor powershell found on PATH' }
$pwsh = $pwshCmd.Source

function Get-WpaiOvernightTask {
    param([string]$Name)
    try {
        return Get-ScheduledTask -TaskName $Name -ErrorAction Stop
    } catch {
        return $null
    }
}

if ($Unregister) {
    $existing = Get-WpaiOvernightTask -Name $TaskName
    if (-not $existing) {
        Write-Host "No scheduled task named '$TaskName' for this user." -ForegroundColor DarkYellow
        return
    }
    if ($WhatIf) {
        Write-Host "Would unregister scheduled task: $TaskName"
        return
    }
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Unregistered scheduled task: $TaskName" -ForegroundColor Green
    return
}

if (-not $Daily -and -not $AtLogOn) {
    throw 'Specify at least one trigger: -Daily (default) and/or -AtLogOn'
}

$argList = "-NoProfile -File `"$wpaiPs1`" overnight start"
$action = New-ScheduledTaskAction -Execute $pwsh -Argument $argList -WorkingDirectory $here

$triggers = @()
if ($Daily) {
    try {
        $tod = [TimeSpan]::Parse($At)
    } catch {
        throw "Invalid -At time '$At' (use HH:mm, e.g. 02:30)"
    }
    $start = [DateTime]::Today.Add($tod)
    if ($start -lt [DateTime]::Now) { $start = $start.AddDays(1) }
    $triggers += New-ScheduledTaskTrigger -Daily -At $start
}
if ($AtLogOn) {
    $triggers += New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
}

# Current-user principal — InteractiveOrRestricted avoids needing admin / highest privileges
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Hours 6)

$description = @(
    'WPAI StudioOps overnight start (current user).'
    'Requires prior arm: wpai overnight arm -ParentTaskIds <id>.'
    'Fails closed when disarmed / kill switch / budget. No daemon.'
) -join ' '

if ($WhatIf) {
    Write-Host 'Would register current-user scheduled task:'
    Write-Host "  Name:        $TaskName"
    Write-Host "  Execute:     $pwsh"
    Write-Host "  Arguments:   $argList"
    Write-Host "  WorkingDir:  $here"
    Write-Host "  Daily:       $Daily  At=$At"
    Write-Host "  AtLogOn:     $AtLogOn"
    Write-Host "  Principal:   $env:USERNAME (Limited, no admin)"
    Write-Host ''
    Write-Host 'NOTE: arm is required first before overnight start does work:'
    Write-Host ("  pwsh -NoProfile -File `"{0}`" overnight arm -ParentTaskIds <parentId>" -f $wpaiPs1)
    return
}

$existing = Get-WpaiOvernightTask -Name $TaskName
if ($existing) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Replacing existing task: $TaskName" -ForegroundColor DarkYellow
}

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $triggers `
    -Principal $principal `
    -Settings $settings `
    -Description $description `
    -Force | Out-Null

Write-Host "Registered scheduled task: $TaskName" -ForegroundColor Green
Write-Host "  $pwsh $argList"
if ($Daily) { Write-Host "  Daily at $At (local)" }
if ($AtLogOn) { Write-Host "  At logon ($env:USERNAME)" }
Write-Host ''
Write-Host 'ARM REQUIRED before a run does work (start disarms after run):' -ForegroundColor Yellow
Write-Host "  pwsh -NoProfile -File `"$wpaiPs1`" overnight arm -ParentTaskIds <parentId> [-MaxRounds 10]"
Write-Host 'Unregister:'
Write-Host "  pwsh -NoProfile -File `"$($MyInvocation.MyCommand.Path)`" -Unregister"
