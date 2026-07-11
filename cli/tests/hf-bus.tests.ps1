# Pester-free tests for hf-bus.ps1 — isolated temp bus, no real Council pollution.
# Run: pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\tests\hf-bus.tests.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$fail = 0
$pass = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) {
        Write-Host "  PASS  $Name" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "  FAIL  $Name" -ForegroundColor Red
        $script:fail++
    }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    if ($Expected -eq $Actual) {
        Write-Host "  PASS  $Name" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "  FAIL  $Name (expected='$Expected' actual='$Actual')" -ForegroundColor Red
        $script:fail++
    }
}

$tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("hf-bus-tests-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null
$bus = Join-Path $tmpRoot 'bus.jsonl'
$env:HF_BUS = $bus
Remove-Item Env:HF_ROLE -ErrorAction SilentlyContinue

try {
    . C:\WPAI\Software\StudioOps\cli\hf-bus.ps1

    Write-Host "hf-bus isolated tests" -ForegroundColor DarkYellow
    Write-Host "bus: $bus"

    # empty bus status
    $s0 = Get-HfBusStatus -Path $bus
    Assert-Equal 0 $s0.Messages 'status empty messages'
    Assert-True ($s0.Path -eq $bus) 'status uses HF_BUS path'

    # post + read
    $m1 = New-HfBusMessage -Text 'hello council' -From 'executor' -To 'orchestrator' -Path $bus
    Assert-equal 'executor' $m1.from 'post from'
    Assert-equal 'orchestrator' $m1.to 'post to'
    Assert-True ($m1.ts -gt 0) 'post timestamp'
    $all = @(Read-HfBus -Path $bus)
    Assert-equal 1 $all.Count 'read count after one post'
    Assert-equal 'hello council' $all[0].text 'read text'

    # role lowercasing
    $m2 = New-HfBusMessage -Text 'ping' -From 'EXECUTOR' -To 'ALL' -Path $bus
    Assert-Equal 'executor' $m2.from 'from lowercased'
    Assert-equal 'all' $m2.to 'to lowercased'

    # garbage lines skipped
    Add-Content -LiteralPath $bus -Value 'not-json' -Encoding utf8
    Add-Content -LiteralPath $bus -Value '' -Encoding utf8
    Add-Content -LiteralPath $bus -Value '{"ts":1,"from":"x","to":"y"}' -Encoding utf8  # no text
    $clean = @(Read-HfBus -Path $bus)
    Assert-equal 2 $clean.Count 'garbage lines skipped'

    # filters
    $null = New-HfBusMessage -Text 'weaponized mind' -From 'director' -To 'all' -Path $bus
    $filt = @(Read-HfBus -Path $bus -From 'director')
    Assert-equal 1 $filt.Count 'filter from director'
    $cont = @(Read-HfBus -Path $bus -Contains 'weaponized')
    Assert-equal 1 $cont.Count 'filter contains'
    $tail = @(Read-HfBus -Path $bus -Count 1)
    Assert-Equal 1 $tail.Count 'tail count'
    Assert-equal 'weaponized mind' $tail[0].text 'tail last message'

    # empty message throws
    $threw = $false
    try { New-HfBusMessage -Text '   ' -Path $bus | Out-Null } catch { $threw = $true }
    Assert-True $threw 'empty message throws'

    # export markdown
    $out = Join-Path $tmpRoot 'export.md'
    $written = Export-HfBusMarkdown -Path $bus -OutFile $out
    Assert-True (Test-Path -LiteralPath $written) 'export file exists'
    $md = Get-Content -LiteralPath $written -Raw
    Assert-True ($md -match 'HellForge Council Bus Export') 'export header'
    Assert-True ($md -match 'weaponized mind') 'export body'

    # format line
    $fmt = Format-HfBusMessage -Message $tail[0] -IsoTime
    Assert-True ($fmt -match 'director -> all') 'format roles'
    Assert-True ($fmt -match 'weaponized mind') 'format text'

    # env role default
    $env:HF_ROLE = 'local'
    $m3 = New-HfBusMessage -Text 'from env role' -Path $bus
    Assert-equal 'local' $m3.from 'HF_ROLE env default'
    Remove-Item Env:HF_ROLE -ErrorAction SilentlyContinue

    # multiline text stays single JSONL line
    $multi = New-HfBusMessage -Text "line1`nline2" -From 'executor' -To 'all' -Path $bus
    $rawLines = @(Get-Content -LiteralPath $bus -Encoding utf8)
    $lastRaw = $rawLines[-1]
    $parsed = $lastRaw | ConvertFrom-Json
    Assert-True ($parsed.text -match 'line1') 'multiline text preserved'
    Assert-True ($lastRaw -notmatch "`n") 'jsonl remains one physical line' 

    # direct script invoke against temp bus
    $env:HF_BUS = $bus
    $null = & pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\hf-bus.ps1 say -Message 'direct-ok' -To all -From executor
    $hit = @(Read-HfBus -Path $bus -Contains 'direct-ok')
    Assert-True ($hit.Count -ge 1) 'direct script invoke say'

    Write-Host ""
    Write-Host ("Results: {0} passed, {1} failed" -f $pass, $fail) -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Red' })
    if ($fail -gt 0) { exit 1 } else { exit 0 }
}
finally {
    Remove-Item Env:HF_BUS -ErrorAction SilentlyContinue
    Remove-Item Env:HF_ROLE -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $tmpRoot) {
        Remove-Item -LiteralPath $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
