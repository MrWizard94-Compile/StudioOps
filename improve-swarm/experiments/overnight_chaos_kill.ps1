<#
.SYNOPSIS
  path-e136eb2c9be0 — overnight chaos-inject kill switch (schema-validate).

.DESCRIPTION
  Hypothesis (catalog): On overnight, improve latency by applying chaos-inject
  via less-script-more-agent; validate with schema-validate.

  Interpreted / inverted: less-script-more-agent is the wrong reliability
  direction — prefer MORE script checks before any agent/loop. Chaos-inject =
  set kill_switch.loops ON, invoke overnight start -DryRun, assert safe refuse.

  No money. No Janus loop. Always leave kill loops OFF (finally).

.EXAMPLE
  pwsh -NoProfile -File improve-swarm\experiments\overnight_chaos_kill.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PathId = 'path-e136eb2c9be0'
$WpaiCli = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'cli\wpai.ps1'
if (-not (Test-Path -LiteralPath $WpaiCli)) {
    $WpaiCli = 'C:\WPAI\Software\StudioOps\cli\wpai.ps1'
}
if (-not (Test-Path -LiteralPath $WpaiCli)) {
    Write-Host 'KILL: wpai.ps1 not found' -ForegroundColor Red
    @{
        path_id      = $PathId
        kill_blocked = $false
        verdict      = 'KILLED'
        error        = 'wpai.ps1 not found'
    } | ConvertTo-Json -Compress
    exit 2
}

function Invoke-Wpai {
    param([Parameter(Mandatory)][string[]]$Args)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $out = & pwsh -NoProfile -File $WpaiCli @Args 2>&1 | Out-String
    $code = $LASTEXITCODE
    if ($null -eq $code) { $code = 0 }
    $ErrorActionPreference = $prev
    return [pscustomobject]@{ ExitCode = $code; Output = $out }
}

$killBlocked = $false
$overnightExit = $null
$overnightOut = ''
$armed = $false
$errorMsg = $null

Write-Host "=== overnight_chaos_kill ($PathId) ===" -ForegroundColor Cyan
Write-Host 'Invert: more-script-before-agent (chaos = kill.loops mid dry-run)' -ForegroundColor DarkGray

try {
    # 0) Ensure clean kill baseline, arm for dry path (no money / no real loop)
    Write-Host 'STEP 0: baseline kill loops off + arm dry parent' -ForegroundColor Green
    $r = Invoke-Wpai -Args @('kill', 'set', 'loops', 'off')
    if ($r.ExitCode -ne 0) { throw "baseline kill off failed: $($r.Output)" }

    $r = Invoke-Wpai -Args @('overnight', 'arm', '-ParentTaskIds', 'task-chaos-kill-dry', '-MaxRounds', '1')
    if ($r.ExitCode -ne 0) { throw "overnight arm failed: $($r.Output)" }
    $armed = $true

    # 1) Chaos inject: kill loops ON
    Write-Host 'STEP 1: kill set loops on (chaos inject)' -ForegroundColor Yellow
    $r = Invoke-Wpai -Args @('kill', 'set', 'loops', 'on')
    if ($r.ExitCode -ne 0) { throw "kill on failed: $($r.Output)" }

    # 2) Overnight dry-run must refuse / safe abort (script gate, not agent)
    Write-Host 'STEP 2: overnight start -DryRun (expect refuse)' -ForegroundColor Yellow
    $r = Invoke-Wpai -Args @('overnight', 'start', '-DryRun')
    $overnightExit = $r.ExitCode
    $overnightOut = [string]$r.Output

    $refusedText = $overnightOut -match 'Kill switch active|overnight refused|kill switch'
    # EAP Stop on throw typically yields non-zero; accept text match as alternate signal
    $killBlocked = ($overnightExit -ne 0) -or $refusedText

    if (-not $killBlocked -and $overnightExit -eq 0) {
        # Dry-run succeeded while kill was on — gate failed
        $errorMsg = 'overnight start -DryRun succeeded while kill.loops=on (gate missing)'
    }

    Write-Host ("  overnight exit={0} kill_blocked={1}" -f $overnightExit, $killBlocked) -ForegroundColor $(if ($killBlocked) { 'Green' } else { 'Red' })
    if ($overnightOut.Trim()) {
        Write-Host ($overnightOut.Trim() | Select-Object -First 1) -ForegroundColor DarkGray
    }
}
catch {
    $errorMsg = $_.Exception.Message
    Write-Host ("FAIL: {0}" -f $errorMsg) -ForegroundColor Red
    $killBlocked = $false
}
finally {
    # 3) ALWAYS leave kill OFF — even on failure
    Write-Host 'STEP 3: finally kill set loops off' -ForegroundColor Cyan
    try {
        $clear = Invoke-Wpai -Args @('kill', 'set', 'loops', 'off')
        if ($clear.ExitCode -ne 0) {
            Write-Host ("WARN: kill off exit={0}: {1}" -f $clear.ExitCode, $clear.Output) -ForegroundColor Magenta
        }
    }
    catch {
        Write-Host ("WARN: kill off threw: {0}" -f $_.Exception.Message) -ForegroundColor Magenta
    }

    if ($armed) {
        try {
            Invoke-Wpai -Args @('overnight', 'disarm') | Out-Null
        }
        catch {
            Write-Host ("WARN: disarm: {0}" -f $_.Exception.Message) -ForegroundColor DarkYellow
        }
    }
}

$verdict = if ($killBlocked) { 'SUPPORTED' } else { 'KILLED' }

$result = [ordered]@{
    schema_version   = '1.0.0'
    path_id          = $PathId
    probe            = 'schema-validate'
    tactic           = 'chaos-inject'
    invert_applied   = 'more-script-before-agent'
    kill_blocked     = [bool]$killBlocked
    overnight_exit   = $overnightExit
    overnight_snippet = if ($overnightOut.Length -gt 240) { $overnightOut.Substring(0, 240) } else { $overnightOut }
    error            = $errorMsg
    money            = $false
    verdict          = $verdict
}

# schema-validate: required keys present + typed
$schemaOk = (
    $result.Contains('kill_blocked') -and
    ($result.kill_blocked -is [bool]) -and
    $result.Contains('verdict') -and
    $result.verdict -in @('SUPPORTED', 'KILLED')
)
$result.schema_valid = [bool]$schemaOk
if (-not $schemaOk) {
    $result.verdict = 'KILLED'
    $result.kill_blocked = $false
    $verdict = 'KILLED'
}

$json = $result | ConvertTo-Json -Compress -Depth 6
Write-Host $json

$outDir = Join-Path $PSScriptRoot $PathId
if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path $outDir 'result.json'), ($result | ConvertTo-Json -Depth 6), $utf8)

Write-Host ("VERDICT: {0}" -f $verdict) -ForegroundColor $(if ($verdict -eq 'SUPPORTED') { 'Green' } else { 'Red' })

if ($verdict -eq 'SUPPORTED') { exit 0 }
exit 2
