# End-to-end self-check for WPAI control plane (no paid services).
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$cli = Split-Path -Parent $MyInvocation.MyCommand.Path
$failed = 0
function Step($name, $script) {
    Write-Host "==> $name" -ForegroundColor Cyan
    try {
        & $script
        Write-Host "  OK $name" -ForegroundColor Green
    } catch {
        Write-Host "  FAIL $name : $($_.Exception.Message)" -ForegroundColor Red
        $script:failed++
    }
}

Step 'unit tests' {
    & pwsh -NoProfile -File (Join-Path $cli 'tests\wpai.tests.ps1')
    if ($LASTEXITCODE -ne 0) { throw "wpai.tests exit $LASTEXITCODE" }
}
Step 'hf-bus tests' {
    & pwsh -NoProfile -File (Join-Path $cli 'tests\hf-bus.tests.ps1')
    if ($LASTEXITCODE -ne 0) { throw "hf-bus.tests exit $LASTEXITCODE" }
}
Step 'status' {
    & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') status | Out-Null
}
Step 'board verify+falsify' {
    & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') board doctor
    if ($LASTEXITCODE -ne 0) { throw "board doctor exit $LASTEXITCODE" }
}
Step 'music check' {
    & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') music check
    if ($LASTEXITCODE -ne 0) { throw "music check failed" }
}
Step 'bridge plan' {
    $job = Join-Path $cli 'templates\example-janus-job.json'
    & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') bridge plan -Job $job | Out-Null
}
Step 'bridge sync' {
    & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') bridge sync | Out-Null
}
Step 'overnight dry' {
    & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') overnight arm -ParentTaskIds 'task-selfcheck-dry' -MaxRounds 1 | Out-Null
    & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') overnight start -DryRun | Out-Null
}
Step 'research gate' {
    & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') research status | Out-Null
}
Step 'janus studio sync' {
    $bin = 'C:\WPAI\AI-Research\Janus\Project-Janus\packages\cli\dist\bin.js'
    if (-not (Test-Path $bin)) { throw "Janus CLI not built: $bin" }
    & node $bin janus studio sync | Out-Null
}
Step 'kill roundtrip' {
    & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') kill set loops on
    if ($LASTEXITCODE -ne 0) { throw "kill on failed: $LASTEXITCODE" }
    & pwsh -NoProfile -File (Join-Path $cli 'wpai.ps1') kill set loops off
    if ($LASTEXITCODE -ne 0) { throw "kill off failed: $LASTEXITCODE" }
}

Write-Host ''
if ($failed -gt 0) {
    Write-Host "SELF-CHECK FAILED: $failed step(s)" -ForegroundColor Red
    exit 1
}
Write-Host 'SELF-CHECK ALL GREEN' -ForegroundColor Green
exit 0
