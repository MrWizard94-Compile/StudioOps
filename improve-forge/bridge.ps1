<#
.SYNOPSIS
  HELL-FORGE SWARM — JSON bridge to the LOCAL improve-swarm engine.
  No web server, no Gemini, no API key. Loads the same StudioOps libs the CLI
  loads, then emits ConvertTo-Json for the Electron desktop app to consume.
.NOTES
  Verbs: status | doctor | ignite | properties | elites
  The swarm's "candidates" are real auto-experiment verdicts (measured SUPPORTED,
  KILLED with counterexample, INCONCLUSIVE) — genuine falsification, not simulated.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Verb = 'status',
    [int]$Limit = 8,
    [int]$Top = 20,
    [int]$Probe = 8,
    [switch]$SelfOnly,
    [string]$Root = '',
    [string]$Path = '',
    [string]$CrawlProfile = '',
    [string]$Only = ''
)
$ErrorActionPreference = 'Stop'

# This app lives in StudioOps\improve-forge; the engine libs are in StudioOps\cli\lib
$cliLib = Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent) 'cli') 'lib'
$loadOrder = @(
    'WpaiCore.ps1', 'WpaiBus.ps1', 'WpaiMusic.ps1', 'WpaiBridge.ps1', 'WpaiOvernight.ps1',
    'WpaiResearch.ps1', 'WpaiImproveSwarm.ps1', 'WpaiBlackboardVerify.ps1',
    'WpaiBudgetLedger.ps1', 'WpaiObserve.ps1'
)
foreach ($lib in $loadOrder) {
    $p = Join-Path $cliLib $lib
    if (Test-Path -LiteralPath $p) { . $p }
}

function Out-Json($obj) { $obj | ConvertTo-Json -Depth 10 -Compress }

try {
    switch ($Verb) {
        'status' {
            # Fast metrics only — never runs the (heavy) reliability gate here.
            $s = Get-WpaiImproveStatus
            $el = Get-WpaiImproveElites
            Out-Json ([ordered]@{
                    ok             = $true
                    catalog_paths  = [int]$s.catalog_paths
                    generation_max = [int]$s.generation_max
                    outcomes       = [int]$s.outcomes
                    bans           = [int]$s.bans
                    kills          = [int]$s.kill_files
                    experiments    = [int]$s.experiment_results
                    elites         = @($el.elites).Count
                })
        }
        'doctor' {
            # The honest reliability gate: runs the real unit suite + property checks.
            $r = Test-WpaiImproveReliability
            Out-Json ([ordered]@{
                    ok            = $true
                    reliable      = [bool]$r.ok
                    outcomes      = [int]$r.outcomes
                    elites        = [int]$r.elites
                    bans          = [int]$r.bans
                    kills         = [int]$r.kills
                    shipped       = [int]$r.shipped
                    unit_tests_ok = $r.unit_tests_ok
                    issues        = @($r.issues)
                })
        }
        'ignite' {
            # Spawn a swarm wave: inject self-targeted recipes so a self-only wave always has
            # fresh survivors, score the genome, then run real auto-experiments (falsify). -Force
            # re-falsifies the top each wave so verdicts are always produced. No API anywhere.
            if ($SelfOnly) { Invoke-WpaiImproveSelfInject -ExtraMutants 24 | Out-Null }
            $gen = Invoke-WpaiImproveGeneration -Top $Top -Probe $Probe -Count 300
            $auto = Invoke-WpaiImproveAutoWave -Limit $Limit -SelfOnly:$SelfOnly -Force
            $learn = Invoke-WpaiImproveLearn
            $cands = @($auto.results | Where-Object { -not ($_.PSObject.Properties.Match('skipped').Count -gt 0 -and $_.skipped) } | ForEach-Object {
                    [ordered]@{
                        id      = [string]$_.path_id
                        verdict = [string]$_.verdict
                        tier    = $(if ($_.PSObject.Properties.Match('evidence_tier').Count) { [string]$_.evidence_tier } else { '' })
                        target  = [string]$_.target
                        tactic  = [string]$_.tactic
                        note    = [string]$_.note
                    }
                })
            Out-Json ([ordered]@{
                    ok           = $true
                    generation   = [int]$gen.generation
                    top_score    = $gen.top_score
                    top          = [string]$gen.top_hypothesis
                    attempted    = [int]$auto.attempted
                    supported    = [int]$auto.supported
                    killed       = [int]$auto.killed
                    inconclusive = [int]$auto.inconclusive
                    candidates   = $cands
                    outcomes     = [int]$learn.outcomes_total
                    bans         = [int]$learn.bans_total
                })
        }
        'properties' {
            $p = Invoke-WpaiImproveProperties -Cases 20
            Out-Json ([ordered]@{
                    ok          = $true
                    all_ok      = [bool]$p.all_ok
                    checked     = [int]$p.checked
                    total_cases = [int]$p.total_cases
                    failed      = @($p.failed)
                    results     = @($p.results | ForEach-Object { [ordered]@{ name = $_.name; ok = [bool]$_.r.ok; cases = [int]$_.r.cases_checked } })
                })
        }
        'elites' {
            $el = Update-WpaiImproveEliteArchive
            $doc = Get-WpaiImproveElites
            $rows = @($doc.elites | ForEach-Object {
                    [ordered]@{
                        id     = [string]$_.path_id
                        target = [string]$_.target
                        lever  = [string]$_.lever
                        tactic = [string]$_.tactic
                        tier   = $(if ($_.PSObject.Properties.Match('evidence_tier').Count) { [string]$_.evidence_tier } else { '' })
                        note   = [string]$_.note
                    }
                })
            Out-Json ([ordered]@{ ok = $true; count = [int]$el.count; elites = $rows })
        }
        'files' {
            # Real source-file tree for the workspace explorer. Bounded to $Root (default:
            # this app's own source — the self-improvement surface). Read-only; excludes
            # build/vendor dirs; capped so a huge tree can't flood the UI.
            $rootReq = if ($Root) { $Root } else { $PSScriptRoot }
            $rootFull = (Resolve-Path -LiteralPath $rootReq -ErrorAction SilentlyContinue).Path
            if (-not $rootFull) { Out-Json ([ordered]@{ ok = $false; error = "root not found: $rootReq" }); break }
            $exts = @('.ps1', '.psm1', '.js', '.cjs', '.mjs', '.ts', '.tsx', '.jsx', '.html', '.css', '.py', '.json', '.md')
            $skip = @('node_modules', '.git', 'dist', '.aether', '__pycache__', 'genome_archive', '.vite')
            $files = @()
            Get-ChildItem -LiteralPath $rootFull -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                if ($exts -notcontains $_.Extension.ToLower()) { return }
                $rel = $_.FullName.Substring($rootFull.Length).TrimStart('\', '/')
                $parts = $rel -split '[\\/]'
                if (@($parts | Where-Object { $skip -contains $_ }).Count -gt 0) { return }
                $files += ($rel -replace '\\', '/')
            }
            $files = @($files | Sort-Object | Select-Object -First 500)
            Out-Json ([ordered]@{ ok = $true; root = $rootFull; count = $files.Count; files = $files })
        }
        'filecontent' {
            # Read one file's content, strictly validated to live under the allowed root.
            # Untrusted path input: resolve + confirm it stays inside root (no '..' traversal).
            $rootReq = if ($Root) { $Root } else { $PSScriptRoot }
            $rootFull = (Resolve-Path -LiteralPath $rootReq -ErrorAction SilentlyContinue).Path
            if (-not $rootFull) { Out-Json ([ordered]@{ ok = $false; error = 'root not found' }); break }
            if (-not $Path) { Out-Json ([ordered]@{ ok = $false; error = 'no path' }); break }
            $target = Join-Path $rootFull $Path
            $targetFull = (Resolve-Path -LiteralPath $target -ErrorAction SilentlyContinue).Path
            if (-not $targetFull -or -not $targetFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
                Out-Json ([ordered]@{ ok = $false; error = 'path outside workspace' }); break
            }
            $content = Get-Content -LiteralPath $targetFull -Raw -ErrorAction SilentlyContinue
            if ($null -eq $content) { $content = '' }
            Out-Json ([ordered]@{ ok = $true; path = ($Path -replace '\\', '/'); bytes = $content.Length; content = $content })
        }
        'solutions' {
            # deep_research_engine banked solutions + genome state, for the Forged Artifacts
            # archive. Real: read straight from the engine's solutions manifest + genome log.
            $root = 'C:\WPAI\AI-Research\deep_research_engine'
            $sman = Join-Path $root 'solutions\solutions_manifest.json'
            $glog = Join-Path $root 'workspace\genome_log.json'
            $sols = @()
            if (Test-Path -LiteralPath $sman) {
                foreach ($s in @(Get-Content -LiteralPath $sman -Raw | ConvertFrom-Json)) {
                    $sols += [ordered]@{
                        generation = [int]$s.generation
                        objective  = [string]$s.objective
                        file       = [string]($s.solution_file -replace '\\', '/')
                        timestamp  = [string]$s.timestamp
                    }
                }
            }
            $gver = 0; $gens = 0; $glast = ''
            if (Test-Path -LiteralPath $glog) {
                $g = @(Get-Content -LiteralPath $glog -Raw | ConvertFrom-Json)
                $gens = $g.Count
                if ($gens -gt 0) { $gver = [int]$g[-1].to_version; $glast = [string]$g[-1].reason }
            }
            Out-Json ([ordered]@{ ok = $true; genome_version = $gver; generations = $gens; last = $glast; count = @($sols).Count; solutions = @($sols) })
        }
        'crawl' {
            # Real open-source harvest -> Smart-Library memory. Runs the GitHubCodeCrawler
            # (official REST API, license allow-list + secret filter), reads the kept snippets
            # from its JSONL store, and best-effort seeds each into the Smart-Library vector
            # store (:8000). Every returned bit is a real repo hit with provenance; seeding is
            # reported honestly (seeded vs harvested, and whether memory was reachable).
            $crawlerDir = 'C:\WPAI\Software\GitHubCodeCrawler'
            $prof = if ($CrawlProfile) { $CrawlProfile } else { 'self-improvement' }
            $only = if ($Only) { $Only } else { 'retry-backoff,property-test' }
            $perPage = [Math]::Max(3, [Math]::Min(12, $Limit))
            $safe = ($prof -replace '[^a-zA-Z0-9._-]', '_')
            $outFile = Join-Path $crawlerDir ("out\" + $safe + "\snippets.jsonl")

            # Authenticate from the gh CLI session if no token env is present.
            $tok = if ($env:GITHUB_TOKEN) { $env:GITHUB_TOKEN } elseif ($env:GH_TOKEN) { $env:GH_TOKEN } else { '' }
            if (-not $tok) { try { $tok = (& gh auth token 2>$null | Select-Object -First 1) } catch {} }

            $ran = $false; $crawlErr = ''
            if (Test-Path -LiteralPath (Join-Path $crawlerDir 'github_code_crawler')) {
                Push-Location -LiteralPath $crawlerDir
                try {
                    if ($tok) { $env:GH_TOKEN = $tok }
                    $pyArgs = @('-m', 'github_code_crawler', 'mission', '--profile', $prof,
                        '--only', $only, '--max-pages', '1', '--per-page', "$perPage")
                    & python @pyArgs 2>&1 | Out-Null
                    $ran = $true
                }
                catch { $crawlErr = $_.Exception.Message }
                finally { Pop-Location }
            }
            else { $crawlErr = 'crawler package not found' }

            # Parse kept snippets from the append-only JSONL store (take the most recent).
            $bits = @(); $kept = 0; $harvested = 0
            if (Test-Path -LiteralPath $outFile) {
                $rows = @()
                foreach ($ln in (Get-Content -LiteralPath $outFile -ErrorAction SilentlyContinue)) {
                    if (-not "$ln".Trim()) { continue }
                    try { $rows += ($ln | ConvertFrom-Json) } catch {}
                }
                $harvested = $rows.Count
                $keptAll = @($rows | Where-Object { $_.kept })
                $kept = $keptAll.Count
                foreach ($r in @($keptAll | Select-Object -Last $perPage)) {
                    $snip = [string]$r.content
                    if ($snip.Length -gt 600) { $snip = $snip.Substring(0, 600) }
                    $bits += [ordered]@{
                        title   = ([string]$r.repo_full_name + ' / ' + [string]$r.path)
                        repo    = [string]$r.repo_full_name
                        path    = [string]$r.path
                        license = [string]$r.license_spdx
                        lang    = [string]$r.language
                        url     = [string]$r.html_url
                        snippet = $snip
                    }
                }
            }

            # Seed kept bits into Smart-Library — best-effort, bounded, honest.
            $memUp = $false; $seeded = 0
            try {
                $h = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/health' -TimeoutSec 5
                $memUp = ($h.status -eq 'ok')
            }
            catch {}
            if ($memUp) {
                foreach ($b in $bits) {
                    try {
                        $lang = if ($b.lang) { $b.lang } else { 'All' }
                        $body = @{
                            content  = ($b.snippet + "`n`n-- source: " + $b.url + " (SPDX " + $b.license + ")")
                            category = 'Crawled Open-Source'
                            language = $lang
                        } | ConvertTo-Json -Compress
                        Invoke-RestMethod -Uri 'http://127.0.0.1:8000/seed' -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 25 | Out-Null
                        $seeded++
                    }
                    catch {}
                }
            }

            Out-Json ([ordered]@{
                    ok        = $true
                    profile   = $prof
                    only      = $only
                    ran       = $ran
                    harvested = $harvested
                    kept      = $kept
                    seeded    = $seeded
                    memory_up = $memUp
                    error     = $crawlErr
                    bits      = @($bits)
                })
        }
        'system' {
            # Real, fail-closed telemetry for every engine in the unified system. A down
            # service reports its true down-state; nothing here is simulated. Each probe is
            # isolated in try/catch so one dead service can never blank the whole report.

            # --- Docker runtime ---
            $docker = [ordered]@{ up = $false; version = ''; containers = @() }
            try {
                $ver = (& docker version --format '{{.Server.Version}}' 2>$null | Select-Object -First 1)
                if ($ver) {
                    $docker.up = $true; $docker.version = "$ver"
                    $rows = & docker ps --format '{{.Names}}|{{.Status}}' 2>$null
                    $cs = @()
                    foreach ($r in @($rows)) {
                        if (-not $r) { continue }
                        $p = $r -split '\|', 2
                        $cs += [ordered]@{ name = $p[0]; status = $(if ($p.Count -gt 1) { $p[1] } else { '' }) }
                    }
                    $docker.containers = $cs
                }
            } catch {}

            # --- Ollama (local models) ---
            $ollama = [ordered]@{ up = $false; models = @(); code_model = $false; reason_model = $false }
            try {
                $r = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/tags' -TimeoutSec 5
                $models = @($r.models | ForEach-Object { [string]$_.name })
                $ollama.up = $true
                $ollama.models = $models
                $ollama.code_model = [bool](@($models) -match 'qwen2\.5-coder')
                $ollama.reason_model = [bool](@($models) -match 'deepseek-r1')
            } catch {}

            # --- JanusPrime orchestrator (the sole mutation engine) ---
            $janus = [ordered]@{ up = $false; memory = 'unknown'; cognition_reachable = $false; assets = $false; tasks_total = 0; tasks_accepted = 0; tasks_pending = 0 }
            try {
                $janusRoot = 'C:\WPAI\AI-Research\Janus'
                $bin = Join-Path $janusRoot 'Project-Janus\packages\cli\dist\bin.js'
                if (Test-Path -LiteralPath $bin) {
                    # The janus CLI walks UP the tree for janus.config.json, so it must run
                    # from inside the Janus workspace — invoke node with that as the cwd.
                    Push-Location -LiteralPath $janusRoot
                    try { $out = & node $bin status 2>$null | Out-String } finally { Pop-Location }
                    $start = $out.IndexOf('{'); $end = $out.LastIndexOf('}')
                    if ($start -ge 0 -and $end -gt $start) {
                        $j = $out.Substring($start, $end - $start + 1) | ConvertFrom-Json
                        $janus.up = $true
                        $janus.memory = [string]$j.memory.status
                        $janus.cognition_reachable = [bool]$j.cognition.reachable
                        $janus.assets = [bool]$j.assets.queue_available
                        $janus.tasks_total = [int]$j.tasks.total
                        if ($j.tasks.by_status) {
                            $janus.tasks_accepted = [int]$j.tasks.by_status.accepted
                            $janus.tasks_pending = [int]$j.tasks.by_status.pending
                        }
                    }
                }
            } catch {}

            # --- deep_research_engine (self-improving genome) ---
            $dre = [ordered]@{ present = $false; genome_version = 0; generations = 0; solutions = 0; last = '' }
            try {
                $root = 'C:\WPAI\AI-Research\deep_research_engine'
                if (Test-Path -LiteralPath $root) {
                    $dre.present = $true
                    $glog = Join-Path $root 'workspace\genome_log.json'
                    if (Test-Path -LiteralPath $glog) {
                        $g = @(Get-Content -LiteralPath $glog -Raw | ConvertFrom-Json)
                        $dre.generations = $g.Count
                        if ($g.Count -gt 0) {
                            $dre.genome_version = [int]$g[-1].to_version
                            $dre.last = [string]$g[-1].reason
                        }
                    }
                    $sman = Join-Path $root 'solutions\solutions_manifest.json'
                    if (Test-Path -LiteralPath $sman) {
                        $dre.solutions = @(Get-Content -LiteralPath $sman -Raw | ConvertFrom-Json).Count
                    }
                }
            } catch {}

            # --- improve-swarm (this engine) ---
            $swarm = [ordered]@{ outcomes = 0; elites = 0; bans = 0; kills = 0; generation = 0 }
            try {
                $s = Get-WpaiImproveStatus
                $el = Get-WpaiImproveElites
                $swarm.outcomes = [int]$s.outcomes
                $swarm.elites = @($el.elites).Count
                $swarm.bans = [int]$s.bans
                $swarm.kills = [int]$s.kill_files
                $swarm.generation = [int]$s.generation_max
            } catch {}

            # --- Smart-Library (semantic memory) — its health is Janus's memory component ---
            $smartlib = [ordered]@{ up = ($janus.memory -eq 'ok'); status = [string]$janus.memory }

            Out-Json ([ordered]@{
                    ok            = $true
                    docker        = $docker
                    ollama        = $ollama
                    janus         = $janus
                    smart_library = $smartlib
                    deep_research = $dre
                    swarm         = $swarm
                })
        }
        default { Out-Json ([ordered]@{ ok = $false; error = "unknown verb: $Verb" }) }
    }
} catch {
    Out-Json ([ordered]@{ ok = $false; error = $_.Exception.Message })
}
