# 30-minute improve-swarm endurance run (UCB1 / tournament / crowding / elitism ports).
# Do not use a parameter named $Args — reserved in PowerShell.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

$logDir = 'C:\WPAI\Workspace\.wpai\improve-swarm'
$cli = 'C:\WPAI\Software\StudioOps\cli\wpai.ps1'
$minutes = 30
if ($args.Count -ge 1) {
    $parsed = 0
    if ([int]::TryParse([string]$args[0], [ref]$parsed) -and $parsed -gt 0) { $minutes = $parsed }
}

$runLog = Join-Path $logDir ("RUN-30MIN-{0:yyyyMMdd-HHmmss}.md" -f (Get-Date))
$deadline = (Get-Date).AddMinutes($minutes)
$wave = 0
$start = Get-Date
$errors = 0

function Invoke-WpaiImproveCmd {
    param([Parameter(Mandatory)][string[]]$CmdArgs)
    $out = & pwsh -NoProfile -File $cli @CmdArgs 2>&1 | ForEach-Object { "$_" }
    $text = ($out -join [Environment]::NewLine)
    # Detect accidental help dump (subcommand never ran)
    if ($text -match 'IMPROVE SWARM \(brute-force' -and $text -notmatch '^(learn:|catalog|generation |mutated|auto-wave|SELF-REVIEW|RELIABLE|NOT RELIABLE|purge:|catalog_paths=)') {
        if ($text -match '(?m)^(learn:|catalog_paths=|generation \d|mutated catalog|auto-wave|SELF-REVIEW|RELIABLE|NOT RELIABLE|purge:|recorded )') {
            return $text
        }
        # If only help, flag
        if (($text -split "`n").Count -gt 40 -and $text -match 'wpai improve seed') {
            throw "CLI returned help instead of running: $($CmdArgs -join ' ')"
        }
    }
    return $text
}

function Write-RunLog([string]$text) {
    Add-Content -LiteralPath $runLog -Value $text -Encoding utf8
    Write-Host $text
}

@"
# Improve swarm endurance run

- **Started:** $($start.ToString('o'))
- **Deadline:** $($deadline.ToString('o'))
- **Duration target:** ${minutes}m
- **Ports:** UCB1 explore, tournament mutate, crowding diversity, HoF elitism
- **Cycle:** learn → mutate → generation → auto -SelfOnly → learn → review

"@ | Set-Content -LiteralPath $runLog -Encoding utf8

Write-RunLog "## Baseline"
try {
    Write-RunLog '```'
    Write-RunLog ((Invoke-WpaiImproveCmd @('improve', 'status')).Trim())
    Write-RunLog '```'
    Write-RunLog ((Invoke-WpaiImproveCmd @('improve', 'doctor')).Trim())
} catch {
    Write-RunLog "BASELINE ERROR: $_"
    $errors++
}

while ((Get-Date) -lt $deadline) {
    $wave++
    $wStart = Get-Date
    $remain = [math]::Round(($deadline - (Get-Date)).TotalMinutes, 1)
    Write-RunLog ""
    Write-RunLog "## Wave $wave (remain ${remain}m) — $($wStart.ToString('HH:mm:ss'))"

    $steps = @(
        @{ name = 'learn'; cmd = @('improve', 'learn') },
        @{ name = 'mutate'; cmd = @('improve', 'mutate', '-Keep', '24', '-Inject', '50') },
        @{ name = 'generation'; cmd = @('improve', 'generation', '-Top', '24', '-Probe', '10') },
        @{ name = 'auto'; cmd = @('improve', 'auto', '-Limit', '8', '-SelfOnly') },
        @{ name = 'learn2'; cmd = @('improve', 'learn') }
    )

    foreach ($step in $steps) {
        Write-RunLog "### $($step.name)"
        try {
            $text = Invoke-WpaiImproveCmd -CmdArgs $step.cmd
            $lines = @($text -split "`r?`n" | Where-Object { $_ -and $_ -notmatch '^\s*$' })
            # Prefer signal lines
            $signal = @($lines | Where-Object {
                    $_ -match '^(learn:|catalog|mutated|generation |auto-wave|SELF-REVIEW|RELIABLE|NOT RELIABLE|purge:|recorded |  \[)'
                })
            if ($signal.Count -gt 0) {
                Write-RunLog (($signal | Select-Object -First 14) -join [Environment]::NewLine)
            } else {
                Write-RunLog (($lines | Select-Object -First 8) -join [Environment]::NewLine)
            }
        } catch {
            Write-RunLog "ERROR $($step.name): $_"
            $errors++
        }
    }

    Write-RunLog "### review"
    try {
        if ($wave % 2 -eq 0) {
            $text = Invoke-WpaiImproveCmd -CmdArgs @('improve', 'review')
            Write-RunLog "_unit tests enabled_"
        } else {
            $text = Invoke-WpaiImproveCmd -CmdArgs @('improve', 'review', '-SkipTests')
            Write-RunLog "_SkipTests_"
        }
        $lines = @($text -split "`r?`n" | Where-Object { $_ -match '^(SELF-REVIEW|unit tests|producing|  \[|RELIABLE|NOT )' })
        Write-RunLog (($lines | Select-Object -First 16) -join [Environment]::NewLine)
    } catch {
        Write-RunLog "ERROR review: $_"
        $errors++
    }

    $leaders = Join-Path $logDir 'LEADERS.md'
    if (Test-Path -LiteralPath $leaders) {
        Write-RunLog "### leaders"
        Write-RunLog ((Get-Content -LiteralPath $leaders -TotalCount 12) -join [Environment]::NewLine)
    }

    $wSec = [math]::Round(((Get-Date) - $wStart).TotalSeconds, 1)
    Write-RunLog "Wave $wave wall: ${wSec}s · errors_so_far=$errors"

    if ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 2
    }
}

Write-RunLog ""
Write-RunLog "## Final"
try {
    Write-RunLog '```'
    Write-RunLog ((Invoke-WpaiImproveCmd @('improve', 'status')).Trim())
    Write-RunLog '```'
    Write-RunLog ((Invoke-WpaiImproveCmd @('improve', 'doctor')).Trim())
    Write-RunLog "### purge"
    Write-RunLog ((Invoke-WpaiImproveCmd @('improve', 'purge')).Trim())
} catch {
    Write-RunLog "FINAL ERROR: $_"
    $errors++
}

$totalMin = [math]::Round(((Get-Date) - $start).TotalMinutes, 2)
Write-RunLog ""
Write-RunLog "Finished: $((Get-Date).ToString('o')) · waves=$wave · total_min=$totalMin · errors=$errors"
Write-RunLog "Log: $runLog"
Write-Host "DONE waves=$wave errors=$errors log=$runLog"
exit $(if ($errors -gt 0 -and $wave -eq 0) { 1 } else { 0 })
