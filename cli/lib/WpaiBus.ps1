# Protocol v2 bus append helpers (HellForge bus.jsonl). No dependency on hf-bus.ps1 entrypoint.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-WpaiBusPath {
    $hf = [string](Get-WpaiConfigValue -Name 'hellforge_dir' -Default 'C:\WPAI\Workspace\.hellforge')
    return (Join-Path $hf 'bus.jsonl')
}

function Write-WpaiBusMessage {
    param(
        [Parameter(Mandatory)][string]$Text,
        [string]$From = 'bridge',
        [string]$To = 'director',
        [string]$Type = 'chat',
        [string]$Path = '',
        [string]$Id = '',
        [string]$Ref = ''
    )
    $bus = Get-WpaiBusPath
    $dir = Split-Path -Parent $bus
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    if (-not (Test-Path -LiteralPath $bus)) {
        New-Item -ItemType File -Force -Path $bus | Out-Null
    }
    $text = ($Text -replace "`r`n", ' ' -replace "`n", ' ').Trim()
    if ($text.Length -gt 400 -and $Type -ne 'chat') {
        $text = $text.Substring(0, 397) + '...'
    }
    if (-not $Id -and $Type -in @('task', 'handoff', 'done', 'block', 'approve_request', 'approve_result', 'budget', 'kill', 'blackboard_sync', 'promotion')) {
        $Id = ([guid]::NewGuid().ToString('N').Substring(0, 8))
    }
    $obj = [ordered]@{
        ts   = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        from = $From.ToLowerInvariant()
        to   = $To.ToLowerInvariant()
        type = $Type.ToLowerInvariant()
        text = $text
    }
    if ($Id) { $obj['id'] = $Id }
    if ($Ref) { $obj['ref'] = $Ref }
    if ($Path) { $obj['path'] = $Path }
    $line = ($obj | ConvertTo-Json -Compress -Depth 6)
    Add-Content -LiteralPath $bus -Value $line -Encoding utf8
    return [pscustomobject]$obj
}

function Invoke-WpaiBusArchive {
    param([int]$KeepLines = 500)
    $bus = Get-WpaiBusPath
    if (-not (Test-Path -LiteralPath $bus)) { return $null }
    $lines = @(Get-Content -LiteralPath $bus -Encoding utf8)
    if ($lines.Count -le $KeepLines) {
        return [pscustomobject]@{ archived = $false; lines = $lines.Count }
    }
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $hf = Split-Path -Parent $bus
    $archDir = Join-Path $hf 'archives'
    if (-not (Test-Path -LiteralPath $archDir)) {
        New-Item -ItemType Directory -Force -Path $archDir | Out-Null
    }
    $archPath = Join-Path $archDir ("bus-{0}.jsonl" -f $stamp)
    $drop = $lines.Count - $KeepLines
    $old = $lines[0..($drop - 1)]
    $keep = $lines[$drop..($lines.Count - 1)]
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($archPath, $old, $utf8)
    [System.IO.File]::WriteAllLines($bus, $keep, $utf8)
    Write-WpaiBusMessage -Text ("bus archived {0} lines -> {1}" -f $drop, $archPath) -Type 'status' -From 'bridge' -To 'all' -Path $archPath | Out-Null
    return [pscustomobject]@{ archived = $true; path = $archPath; moved = $drop; kept = $keep.Count }
}
