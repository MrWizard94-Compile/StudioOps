<#
.SYNOPSIS
  Validate StudioOps site assets + bus CLI health.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$failed = 0

function Ok($msg) { Write-Host "  OK  $msg" -ForegroundColor Green }
function Bad($msg) { Write-Host "  BAD $msg" -ForegroundColor Red; $script:failed++ }

Write-Host "StudioOps self-check" -ForegroundColor DarkYellow

$required = @(
    'C:\WPAI\Software\StudioOps\site\index.html',
    'C:\WPAI\Software\StudioOps\site\products.html',
    'C:\WPAI\Software\StudioOps\site\studio.html',
    'C:\WPAI\Software\StudioOps\site\about.html',
    'C:\WPAI\Software\StudioOps\site\contact.html',
    'C:\WPAI\Software\StudioOps\site\css\styles.css',
    'C:\WPAI\Software\StudioOps\site\js\site.js',
    'C:\WPAI\Software\StudioOps\site\assets\logo-horizontal.png',
    'C:\WPAI\Software\StudioOps\site\assets\hero-forge.jpg',
    'C:\WPAI\Software\StudioOps\site\assets\repoforge-bg.jpg',
    'C:\WPAI\Software\StudioOps\site\assets\mixin-bg.jpg',
    'C:\WPAI\Software\StudioOps\site\assets\lane-music.jpg',
    'C:\WPAI\Software\StudioOps\site\assets\lane-software.jpg',
    'C:\WPAI\Software\StudioOps\site\assets\lane-games.jpg',
    'C:\WPAI\Software\StudioOps\site\assets\founder-portrait.jpg',
    'C:\WPAI\Software\StudioOps\site\assets\products-bg.jpg',
    'C:\WPAI\Software\StudioOps\site\assets\backdrop.png',
    'C:\WPAI\Software\StudioOps\cli\hf-bus.ps1',
    'C:\WPAI\Software\StudioOps\README.md'
)
foreach ($p in $required) {
    if (Test-Path -LiteralPath $p) { Ok $p } else { Bad "missing $p" }
}

$html = Get-Content 'C:\WPAI\Software\StudioOps\site\index.html' -Raw
foreach ($ref in @('css/styles.css', 'js/site.js', 'assets/hero-forge.jpg', 'assets/repoforge-bg.jpg', 'assets/mixin-bg.jpg', 'wpaistudio.gumroad.com/l/repoforge', 'mixin-field-manual', 'rob@wpaistudio.net', 'products.html', 'studio.html')) {
    if ($html -like "*$ref*") { Ok "index contains $ref" } else { Bad "index missing $ref" }
}

$products = Get-Content 'C:\WPAI\Software\StudioOps\site\products.html' -Raw
foreach ($ref in @('Buy RepoForge Pro', 'Mixin Field Manual', '$14', '$29')) {
    if ($products.Contains($ref)) { Ok "products contains $ref" } else { Bad "products missing $ref" }
}

. C:\WPAI\Software\StudioOps\cli\hf-bus.ps1
try {
    $s = Get-HfBusStatus
    Ok ("bus path {0} ({1} msgs)" -f $s.Path, $s.Messages)
    $probe = "self-check $(Get-Date -Format o)"
    $null = New-HfBusMessage -Text $probe -To 'all' -From 'executor'
    $hit = @(Read-HfBus -Count 3 | Where-Object { $_.text -eq $probe })
    if ($hit.Count -ge 1) { Ok 'bus round-trip post/read' } else { Bad 'bus round-trip failed' }
} catch {
    Bad ("cli error: {0}" -f $_.Exception.Message)
}

Write-Host "Running isolated CLI unit tests..." -ForegroundColor DarkYellow
& pwsh -NoProfile -File 'C:\WPAI\Software\StudioOps\cli\tests\hf-bus.tests.ps1'
if ($LASTEXITCODE -ne 0) {
    Bad 'cli unit tests failed'
} else {
    Ok 'cli unit tests (24 assertions)'
}

if ($failed -eq 0) {
    Write-Host "ALL CHECKS PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "$failed CHECK(S) FAILED" -ForegroundColor Red
    exit 1
}

