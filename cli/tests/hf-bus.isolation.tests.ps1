# Real disposable-file isolation tests; no production Council state is touched.
[CmdletBinding()]
param([string]$CliPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'hf-bus.ps1'))

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$pass = 0
$fail = 0
function Assert-Isolated([bool]$Condition, [string]$Name) {
    if ($Condition) { $script:pass++; Write-Host "PASS $Name" }
    else { $script:fail++; Write-Host "FAIL $Name" }
}

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar)
$testRoot = Join-Path $tempBase ('studioops-bus-isolation-' + [guid]::NewGuid().ToString('N'))
$savedBus = $env:HF_BUS
New-Item -ItemType Directory -Path $testRoot | Out-Null
try {
    Remove-Item Env:HF_BUS -ErrorAction SilentlyContinue
    . $CliPath
    # Resolution only: never invoke a default-root operation against production.
    Assert-Isolated ((Get-HfBusPath) -eq 'C:\WPAI\Workspace\.hellforge\bus.jsonl') 'production default bus is unchanged'

    # Retarget legacy defaults to a disposable sentinel, so this same test can
    # safely falsify the original implementation without writing real inboxes.
    $sentinel = Join-Path $testRoot 'unused-default'
    $script:HfBusDefaultDir = $sentinel
    $script:HfBusDefaultPath = Join-Path $sentinel 'bus.jsonl'
    $script:HfHandoffsDir = Join-Path $sentinel 'handoffs'
    $script:HfInboxDir = Join-Path $sentinel 'inbox'
    $script:HfStatusPath = Join-Path $sentinel 'STATUS.md'
    $script:HfProtocolPath = Join-Path $sentinel 'PROTOCOL.md'

    $rootA = Join-Path $testRoot '[fixture A]'
    $rootB = Join-Path $testRoot 'fixture B'
    $busA = Join-Path $rootA 'bus.jsonl'
    $busB = Join-Path $rootB 'bus.jsonl'
    $env:HF_BUS = $busA
    $null = New-HfBusMessage -Text 'environment-A' -From executor -To orchestrator
    $inboxA = Join-Path $rootA 'inbox/orchestrator.jsonl'
    Assert-Isolated (Test-Path -LiteralPath $inboxA) 'HF_BUS redirects inbox files including literal bracket paths'
    Assert-Isolated (Test-Path -LiteralPath (Join-Path $rootA 'handoffs')) 'HF_BUS redirects handoff directory'
    Assert-Isolated (-not (Test-Path -LiteralPath $sentinel)) 'custom bus does not create default Council state'
    Assert-Isolated (@(Read-HfBus -Path $busA -Contains 'environment-A').Count -eq 1) 'custom bus retains message'

    $null = New-HfBusMessage -Text 'explicit-B' -From executor -To orchestrator -Path $busB
    $inboxB = Join-Path $rootB 'inbox/orchestrator.jsonl'
    Assert-Isolated (Test-Path -LiteralPath $inboxB) 'explicit Path redirects its own inbox despite HF_BUS'
    Assert-Isolated (@(Read-HfBus -Path $inboxA -Contains 'explicit-B').Count -eq 0) 'explicit Path does not leak into environment inbox'
    $statusB = Get-HfBusStatus -Path $busB
    Assert-Isolated ($statusB.Path -eq $busB) 'explicit status uses selected bus'
    Assert-Isolated ($statusB.StatusPath -eq (Join-Path $rootB 'STATUS.md')) 'status path shares selected root'
    Assert-Isolated ($statusB.ProtocolPath -eq (Join-Path $rootB 'PROTOCOL.md')) 'protocol path shares selected root'

    $null = hf-bus handoff -Path $busB -Title 'isolation' -Body 'fixture handoff' -From executor -To orchestrator
    $handoffsB = @(Get-ChildItem -LiteralPath (Join-Path $rootB 'handoffs') -File -ErrorAction SilentlyContinue)
    Assert-Isolated ($handoffsB.Count -eq 1) 'explicit handoff writes only selected directory'
    Assert-Isolated ((Get-HfBusStatus -Path $busB).Handoffs -eq 1) 'handoff count reads selected directory'
    $null = hf-bus export -Path $busB
    $exportsB = @(Get-ChildItem -LiteralPath (Join-Path $rootB 'exports') -File -ErrorAction SilentlyContinue)
    Assert-Isolated ($exportsB.Count -eq 1) 'default export filename stays in selected Council root'

    Set-Content -LiteralPath (Join-Path $rootB 'STATUS.md') -Value 'fixture-board-B'
    Set-Content -LiteralPath (Join-Path $rootB 'PROTOCOL.md') -Value 'fixture-protocol-B'
    Assert-Isolated ((@(hf-bus board -Path $busB) -join '') -eq 'fixture-board-B') 'board reads selected root'
    Assert-Isolated ((@(hf-bus protocol -Path $busB) -join '') -eq 'fixture-protocol-B') 'protocol reads selected root'

    $env:HF_BUS = $busB
    $null = New-HfBusMessage -Text 'environment-B-after-load' -From executor -To orchestrator
    Assert-Isolated (@(Read-HfBus -Path $inboxB -Contains 'environment-B-after-load').Count -eq 1) 'HF_BUS change after import redirects inbox dynamically'
    Assert-Isolated (@(Read-HfBus -Path $inboxA -Contains 'environment-B-after-load').Count -eq 0) 'changed environment does not leak to previous inbox'
    Assert-Isolated (-not (Test-Path -LiteralPath $sentinel)) 'no operation fell back to default Council state'

    Push-Location -LiteralPath $rootA
    try {
        Assert-Isolated ((Get-HfBusPath -Path './relative-bus.jsonl') -eq (Join-Path $rootA 'relative-bus.jsonl')) 'relative bus follows PowerShell location without requiring an existing file'
    } finally { Pop-Location }
    $rejectedProvider = $false
    try { $null = Get-HfBusPath -Path 'Env:HF_BUS' } catch { $rejectedProvider = $true }
    Assert-Isolated $rejectedProvider 'non-filesystem provider is rejected before any mutation'

    $rejectedRoot = Join-Path $testRoot 'rejected-input'
    $rejectedRecipient = $false
    try {
        $null = New-HfBusMessage -Text 'must not be appended' -To '../escape' -Path (Join-Path $rejectedRoot 'bus.jsonl')
    } catch { $rejectedRecipient = $true }
    Assert-Isolated $rejectedRecipient 'recipient path separators are rejected'
    Assert-Isolated (-not (Test-Path -LiteralPath $rejectedRoot)) 'rejected recipient creates no bus or Council directory'
    $countBeforeRejected = @(Read-HfBus -Path $busB).Count
    $rejectedSender = $false
    try { $null = Write-HfHandoffFile -Title 'invalid sender' -Body 'must not write' -From '../sender' -Path $busB }
    catch { $rejectedSender = $true }
    Assert-Isolated $rejectedSender 'handoff sender cannot escape filename component'
    Assert-Isolated (@(Read-HfBus -Path $busB).Count -eq $countBeforeRejected) 'rejected handoff leaves bus unchanged'

    $dispatchRoot = Join-Path $testRoot 'rejected-dispatch'
    $dispatchRejected = $false
    try { $null = hf-bus say -Message 'must not append' -To '../escape' -Path (Join-Path $dispatchRoot 'bus.jsonl') }
    catch { $dispatchRejected = $true }
    Assert-Isolated $dispatchRejected 'CLI dispatcher rejects recipient path separators'
    Assert-Isolated (-not (Test-Path -LiteralPath $dispatchRoot)) 'CLI rejection occurs before Council initialization'
    $handoffRejectedRoot = Join-Path $testRoot 'rejected-handoff-dispatch'
    $handoffDispatchRejected = $false
    try { $null = hf-bus handoff -Title 'invalid' -Body 'must not write' -From '../sender' -Path (Join-Path $handoffRejectedRoot 'bus.jsonl') }
    catch { $handoffDispatchRejected = $true }
    Assert-Isolated $handoffDispatchRejected 'CLI dispatcher rejects unsafe handoff sender'
    Assert-Isolated (-not (Test-Path -LiteralPath $handoffRejectedRoot)) 'CLI sender rejection creates no Council state'

    Write-Host "Isolation results: $pass passed, $fail failed"
    if ($fail -ne 0) { exit 1 }
} finally {
    if ($null -eq $savedBus) { Remove-Item Env:HF_BUS -ErrorAction SilentlyContinue }
    else { $env:HF_BUS = $savedBus }
    $cleanupTarget = [IO.Path]::GetFullPath($testRoot)
    if ([IO.Path]::GetDirectoryName($cleanupTarget) -ne $tempBase -or
        [IO.Path]::GetFileName($cleanupTarget) -notmatch '^studioops-bus-isolation-[a-f0-9]{32}$') {
        throw 'Refusing cleanup outside this exact disposable test directory.'
    }
    if (Test-Path -LiteralPath $cleanupTarget) {
        $entries = @((Get-Item -LiteralPath $cleanupTarget -Force)) + @(Get-ChildItem -LiteralPath $cleanupTarget -Recurse -Force)
        if (@($entries | Where-Object { ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 }).Count) {
            throw 'Refusing recursive cleanup through a linked fixture path.'
        }
        Remove-Item -LiteralPath $cleanupTarget -Recurse -Force
    }
}
