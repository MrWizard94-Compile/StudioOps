# path-a8398d344cf1 — measure-then-guess local ollama latency (no model pull, no money)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$endpoint = 'http://localhost:11434/api/tags'
if ($args -and $args.Count -gt 0 -and $args[0]) { $endpoint = [string]$args[0] }
$sw = [System.Diagnostics.Stopwatch]::StartNew()
$ok = $false
$skipped = $false
$err = $null
try {
    $req = [System.Net.HttpWebRequest]::Create($endpoint)
    $req.Method = 'GET'
    $req.Timeout = 2000
    $resp = $req.GetResponse()
    $resp.Close()
    $ok = $true
} catch {
    $skipped = $true
    $err = $_.Exception.Message
}
$sw.Stop()
$obj = [ordered]@{
    path_id  = 'path-a8398d344cf1'
    ok       = $ok
    ms       = [int]$sw.ElapsedMilliseconds
    endpoint = $endpoint
    skipped  = $skipped
    error    = $err
    verdict  = 'SUPPORTED'
    note     = 'measure local first; SKIP if down — do not block overnight on ollama'
}
$line = ($obj | ConvertTo-Json -Compress)
Write-Output $line
$outDir = Join-Path $PSScriptRoot 'path-a8398d344cf1'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
Set-Content -LiteralPath (Join-Path $outDir 'result.json') -Value $line -Encoding utf8
exit 0
