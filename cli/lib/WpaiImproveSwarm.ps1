# Brute-force improve swarm — path genome, scoring, generation, briefs.
# Explore hundreds of unconventional paths; converge by fitness. No paid APIs.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-WpaiImproveSwarmRoot {
    return 'C:\WPAI\Software\StudioOps\improve-swarm'
}

function Get-WpaiImproveRuntimeDir {
    $d = Join-Path (Get-WpaiConfigValue -Name 'wpai_dir' -Default 'C:\WPAI\Workspace\.wpai') 'improve-swarm'
    if (-not (Test-Path -LiteralPath $d)) {
        New-Item -ItemType Directory -Force -Path $d | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $d 'briefs') | Out-Null
    }
    return $d
}

function Get-WpaiImproveCatalogPath {
    $root = Get-WpaiImproveSwarmRoot
    $paths = Join-Path $root 'paths'
    if (-not (Test-Path -LiteralPath $paths)) {
        New-Item -ItemType Directory -Force -Path $paths | Out-Null
    }
    return (Join-Path $paths 'catalog.jsonl')
}

function New-WpaiImprovePathId {
    param([string]$Seed)
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($Seed)
    )
    $hex = ($hash | ForEach-Object { $_.ToString('x2') }) -join ''
    return 'path-' + $hex.Substring(0, 12)
}

function Get-WpaiImproveDimensions {
    return @{
        targets = @(
            'studioops-cli', 'studioops-blackboard', 'hellforge-ui', 'hellforge-bus',
            'janus-loop', 'janus-validation', 'janus-memory', 'music-pipeline',
            'gaming-mod', 'omni32-assets', 'research-genome', 'cross-brand',
            'token-budget', 'overnight', 'hitl-approvals', 'observability'
        )
        levers = @(
            'latency', 'reliability', 'dx', 'security', 'autonomy', 'observability',
            'token-cost', 'ux', 'legal-hygiene', 'novelty', 'idempotency', 'determinism',
            'locality', 'throughput', 'simplicity', 'reversibility'
        )
        tactics = @(
            'cache', 'precompute', 'lazy', 'eager', 'batch', 'stream', 'queue',
            'delete-abstraction', 'merge-layers', 'split-concern', 'invert-control',
            'fail-closed', 'fail-open-probe', 'double-entry', 'shadow-mode',
            'property-test', 'fuzz', 'chaos-inject', 'starve-input', 'flood-input',
            'single-writer', 'append-only', 'event-source', 'snapshot',
            'genome-mutate', 'canary', 'rollback-first', 'measurement-first',
            'remove-feature', 'rename-for-truth', 'document-only', 'test-only',
            'bus-not-call', 'blackboard-not-chat', 'janus-not-direct-write',
            'local-ollama', 'cut-context', 'raise-context', 'idle-game-ops'
        )
        inverts = @(
            'none', 'invert-assumption', 'do-opposite', 'remove-instead-of-add',
            'slow-down-to-speed-up', 'less-agent-more-script', 'less-script-more-agent',
            'human-before-auto', 'auto-before-human-for-drafts', 'measure-then-guess',
            'guess-then-falsify', 'copy-domain-foreign', 'borrow-from-idle-games',
            'borrow-from-compilers', 'borrow-from-avionics', 'borrow-from-accounting'
        )
        probes = @(
            'static-score', 'grep-fit', 'self-check', 'unit-test', 'micro-bench',
            'dry-run-script', 'schema-validate', 'property-quick', 'docs-delta'
        )
    }
}

function New-WpaiImproveHypothesis {
    param(
        [string]$Target,
        [string]$Lever,
        [string]$Tactic,
        [string]$Invert,
        [string]$Probe
    )
    $invBit = if ($Invert -eq 'none') { '' } else { " via $Invert" }
    return "On $Target, improve $Lever by applying $Tactic$invBit; validate with $Probe."
}

function Initialize-WpaiImproveCatalog {
    param([int]$Count = 300, [switch]$Force)
    $catalog = Get-WpaiImproveCatalogPath
    if ((Test-Path -LiteralPath $catalog) -and -not $Force) {
        $n = @(Get-Content -LiteralPath $catalog -ErrorAction SilentlyContinue).Count
        if ($n -ge $Count) {
            return [pscustomobject]@{ path = $catalog; count = $n; regenerated = $false }
        }
    }
    $dim = Get-WpaiImproveDimensions
    $rng = [System.Random]::new(0x57424149) # fixed seed for reproducibility; reseed with Force+time below
    if ($Force) { $rng = [System.Random]::new([int]([DateTime]::UtcNow.Ticks % [int]::MaxValue)) }

    $lines = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    $guard = 0
    while ($lines.Count -lt $Count -and $guard -lt ($Count * 40)) {
        $guard++
        $t = $dim.targets[$rng.Next($dim.targets.Count)]
        $l = $dim.levers[$rng.Next($dim.levers.Count)]
        $tac = $dim.tactics[$rng.Next($dim.tactics.Count)]
        $inv = $dim.inverts[$rng.Next($dim.inverts.Count)]
        $pr = $dim.probes[$rng.Next($dim.probes.Count)]
        # Bias: ~35% unconventional invert
        if ($rng.NextDouble() -gt 0.35) { $inv = 'none' }
        $seed = "$t|$l|$tac|$inv|$pr"
        if ($seen.ContainsKey($seed)) { continue }
        $seen[$seed] = $true
        $id = New-WpaiImprovePathId -Seed $seed
        $unconventional = ($inv -ne 'none') -or ($tac -in @('delete-abstraction', 'remove-feature', 'starve-input', 'flood-input', 'invert-control', 'guess-then-falsify', 'borrow-from-idle-games', 'borrow-from-avionics'))
        $risk = 'low'
        if ($t -match 'music|brand|gaming') { $risk = 'med' }
        if ($tac -match 'fail-open|flood' -or $l -eq 'autonomy') { $risk = 'med' }
        if ($t -match 'publish|distro' -or $l -match 'money') { $risk = 'high' }
        $cost = 'cheap'
        if ($pr -in @('micro-bench', 'self-check')) { $cost = 'medium' }
        if ($pr -eq 'property-quick' -and $t -match 'janus') { $cost = 'medium' }

        $obj = [ordered]@{
            schema_version  = '1.0.0'
            id              = $id
            target          = $t
            lever           = $l
            tactic          = $tac
            invert          = $inv
            probe           = $pr
            hypothesis      = (New-WpaiImproveHypothesis -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr)
            unconventional  = $unconventional
            risk            = $risk
            cost_to_try     = $cost
            status          = 'candidate'
            generation_born = 0
        }
        $lines.Add(($obj | ConvertTo-Json -Compress -Depth 6))
    }

    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($catalog, $lines, $utf8)
    return [pscustomobject]@{ path = $catalog; count = $lines.Count; regenerated = $true }
}

function Read-WpaiImproveCatalog {
    $catalog = Get-WpaiImproveCatalogPath
    if (-not (Test-Path -LiteralPath $catalog)) {
        Initialize-WpaiImproveCatalog -Count 300 | Out-Null
    }
    $out = @()
    foreach ($line in Get-Content -LiteralPath $catalog -Encoding utf8) {
        $trim = $line.Trim()
        if (-not $trim) { continue }
        try { $out += ($trim | ConvertFrom-Json) } catch { }
    }
    return $out
}

function Test-WpaiImproveCodebaseFit {
    param($PathObj)
    $score = 0.15
    $hits = @()
    $map = @{
        'studioops-cli'       = 'C:\WPAI\Software\StudioOps\cli'
        'studioops-blackboard'= 'C:\WPAI\Workspace\.wpai'
        'hellforge-ui'        = 'C:\WPAI\Software\HellForge\renderer'
        'hellforge-bus'       = 'C:\WPAI\Software\HellForge'
        'janus-loop'          = 'C:\WPAI\AI-Research\Janus\Project-Janus\packages\janus-integrations'
        'janus-validation'    = 'C:\WPAI\AI-Research\Janus\Project-Janus\packages\validation-kernel'
        'janus-memory'        = 'C:\WPAI\AI-Research\Janus\Smart-Library'
        'music-pipeline'      = 'C:\WPAI\Music'
        'gaming-mod'          = 'C:\WPAI\Gaming'
        'omni32-assets'       = 'C:\WPAI\AI-Research\AssetConverter'
        'research-genome'     = 'C:\WPAI\AI-Research\deep_research_engine'
        'overnight'           = 'C:\WPAI\Software\StudioOps\cli\lib\WpaiOvernight.ps1'
        'hitl-approvals'      = 'C:\WPAI\Workspace\.wpai\approvals'
        'token-budget'        = 'C:\WPAI\AI-Research\Janus\janus.config.json'
        'observability'       = 'C:\WPAI\Software\StudioOps'
        'cross-brand'         = 'C:\WPAI\Brand'
    }
    $t = [string]$PathObj.target
    if ($map.ContainsKey($t) -and (Test-Path -LiteralPath $map[$t])) {
        $score += 0.45
        $hits += $map[$t]
    }
    # Tactic keywords present in nearby docs/code names
    $kw = [string]$PathObj.tactic
    if ($kw -match 'bus|blackboard|janus|genome|cache|fuzz') { $score += 0.15 }
    if ($PathObj.unconventional) { $score += 0.05 }
    return [pscustomobject]@{ score = [math]::Min(1.0, $score); hits = $hits }
}

function Get-WpaiImproveFitness {
    param($PathObj)
    $fit = Test-WpaiImproveCodebaseFit -PathObj $PathObj
    $novelty = 0.2
    if ($PathObj.unconventional) { $novelty += 0.35 }
    if ([string]$PathObj.invert -ne 'none') { $novelty += 0.25 }
    if ([string]$PathObj.tactic -match 'delete|remove|starve|invert|borrow-from') { $novelty += 0.15 }
    $novelty = [math]::Min(1.0, $novelty)

    $measurable = 0.2
    if ([string]$PathObj.lever -match 'latency|token|throughput|reliability|determinism') { $measurable = 0.85 }
    elseif ([string]$PathObj.lever -match 'observability|idempotency') { $measurable = 0.65 }

    $riskPen = 0.0
    if ([string]$PathObj.risk -eq 'med') { $riskPen = 0.12 }
    if ([string]$PathObj.risk -eq 'high') { $riskPen = 0.45 }

    $costBoost = 0.1
    if ([string]$PathObj.cost_to_try -eq 'cheap') { $costBoost = 0.35 }
    elseif ([string]$PathObj.cost_to_try -eq 'medium') { $costBoost = 0.2 }

    # Prefer probes we can actually run locally
    $probeBoost = 0.15
    if ([string]$PathObj.probe -in @('static-score', 'grep-fit', 'schema-validate', 'docs-delta')) { $probeBoost = 0.4 }
    if ([string]$PathObj.probe -in @('unit-test', 'self-check', 'dry-run-script')) { $probeBoost = 0.3 }

    $raw =
        0.28 * $fit.score +
        0.22 * $novelty +
        0.22 * $measurable +
        0.12 * $costBoost +
        0.16 * $probeBoost -
        $riskPen

    $score = [math]::Round([math]::Max(0.0, [math]::Min(1.0, $raw)), 4)
    return [pscustomobject]@{
        id           = $PathObj.id
        score        = $score
        fit          = $fit.score
        novelty      = [math]::Round($novelty, 4)
        measurable   = $measurable
        risk_penalty = $riskPen
        cost_to_try  = [string]$PathObj.cost_to_try
        unconventional = [bool]$PathObj.unconventional
        hypothesis   = [string]$PathObj.hypothesis
        target       = [string]$PathObj.target
        lever        = [string]$PathObj.lever
        tactic       = [string]$PathObj.tactic
        invert       = [string]$PathObj.invert
        probe        = [string]$PathObj.probe
        hits         = $fit.hits
    }
}

function Invoke-WpaiImproveProbe {
    param($RankedPath)
    # Cheap probes only — no paid APIs. Returns probe_result object.
    $ok = $true
    $detail = 'static-ok'
    $probe = [string]$RankedPath.probe
    try {
        switch ($probe) {
            'grep-fit' {
                $detail = "fit=$($RankedPath.fit) hits=$($RankedPath.hits -join ';')"
                $ok = $RankedPath.fit -ge 0.4
            }
            'schema-validate' {
                $ok = $RankedPath.hypothesis.Length -gt 20
                $detail = 'hypothesis present'
            }
            'static-score' {
                $ok = $RankedPath.score -ge 0.35
                $detail = "score=$($RankedPath.score)"
            }
            'docs-delta' {
                $ok = $true
                $detail = 'docs probe deferred to brief'
            }
            'dry-run-script' {
                if ($RankedPath.target -match 'studioops|overnight|hitl') {
                    $ok = Test-Path 'C:\WPAI\Software\StudioOps\cli\wpai.ps1'
                    $detail = 'wpai present'
                } else { $detail = 'dry-run n/a'; $ok = $true }
            }
            'self-check' {
                # Do not run full self-check per path (too slow); signal only
                $ok = Test-Path 'C:\WPAI\Software\StudioOps\cli\Self-Check-Wpai.ps1'
                $detail = 'self-check script exists (not re-run per path)'
            }
            'unit-test' {
                $ok = Test-Path 'C:\WPAI\Software\StudioOps\cli\tests\wpai.tests.ps1'
                $detail = 'unit harness exists'
            }
            default {
                $detail = "probe $probe scored statically"
                $ok = $RankedPath.score -ge 0.3
            }
        }
    } catch {
        $ok = $false
        $detail = $_.Exception.Message
    }
    return [pscustomobject]@{
        id     = $RankedPath.id
        ok     = $ok
        detail = $detail
        probe  = $probe
    }
}

function Invoke-WpaiImproveGeneration {
    param(
        [int]$Top = 40,
        [int]$Probe = 12,
        [int]$Count = 300
    )
    Initialize-WpaiImproveCatalog -Count $Count | Out-Null
    $catalog = @(Read-WpaiImproveCatalog)
    $ranked = @()
    foreach ($p in $catalog) {
        $ranked += Get-WpaiImproveFitness -PathObj $p
    }
    $ranked = $ranked | Sort-Object score -Descending

    $toProbe = @($ranked | Select-Object -First ([math]::Max($Probe, 1)))
    $probeResults = @()
    foreach ($r in $toProbe) {
        $probeResults += Invoke-WpaiImproveProbe -RankedPath $r
    }
    $probeMap = @{}
    foreach ($pr in $probeResults) { $probeMap[$pr.id] = $pr }

    # Adjust score: failed probe demotes
    $final = @()
    foreach ($r in $ranked) {
        $s = [double]$r.score
        $probeOk = $true
        $probeDetail = ''
        if ($probeMap.ContainsKey($r.id)) {
            $probeOk = [bool]$probeMap[$r.id].ok
            $probeDetail = [string]$probeMap[$r.id].detail
            if (-not $probeOk) { $s = [math]::Round($s * 0.45, 4) }
            else { $s = [math]::Round([math]::Min(1.0, $s + 0.05), 4) }
        }
        $final += [pscustomobject]@{
            id             = $r.id
            score          = $s
            prior_score    = $r.score
            fit            = $r.fit
            novelty        = $r.novelty
            measurable     = $r.measurable
            unconventional = $r.unconventional
            risk_penalty   = $r.risk_penalty
            cost_to_try    = $r.cost_to_try
            hypothesis     = $r.hypothesis
            target         = $r.target
            lever          = $r.lever
            tactic         = $r.tactic
            invert         = $r.invert
            probe          = $r.probe
            probe_ok       = $probeOk
            probe_detail   = $probeDetail
            hits           = $r.hits
        }
    }
    $final = $final | Sort-Object score -Descending
    $survivors = @($final | Select-Object -First $Top)

    $rt = Get-WpaiImproveRuntimeDir
    $genIdx = 0
    $existing = @(Get-ChildItem -LiteralPath $rt -Filter 'generation-*.json' -File -ErrorAction SilentlyContinue)
    if ($existing.Count -gt 0) {
        $nums = $existing | ForEach-Object {
            if ($_.BaseName -match 'generation-(\d+)') { [int]$Matches[1] } else { 0 }
        }
        $genIdx = ([int]($nums | Measure-Object -Maximum).Maximum) + 1
    }
    $genName = 'generation-{0:D4}' -f $genIdx
    $genPath = Join-Path $rt ($genName + '.json')

    $payload = [ordered]@{
        schema_version = '1.0.0'
        generation     = $genIdx
        created_at     = (Get-WpaiUtcNow)
        catalog_size   = $catalog.Count
        top            = $Top
        probed         = $Probe
        philosophy     = 'diverge-hundreds → probe-cheap → converge-survivors → mutate'
        survivors      = @($survivors)
        probed_ids     = @($toProbe | ForEach-Object { $_.id })
        all_top_scores = @($final | Select-Object -First 20 | ForEach-Object { @{ id = $_.id; score = $_.score } })
    }
    Write-WpaiJsonAtomic -Path $genPath -Object $payload

    # Leaders markdown
    $leaders = Join-Path $rt 'LEADERS.md'
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("# Improve Swarm Leaders — generation $genIdx")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("Scored $($catalog.Count) paths · survivors $Top · probed $Probe")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| Rank | Score | Unconv | Target | Lever | Tactic | Hypothesis |")
    [void]$sb.AppendLine("|-----:|------:|:------:|--------|-------|--------|------------|")
    $rank = 0
    foreach ($s in $survivors) {
        $rank++
        $u = if ($s.unconventional) { 'Y' } else { '' }
        $hyp = ($s.hypothesis -replace '\|', '/')
        if ($hyp.Length -gt 90) { $hyp = $hyp.Substring(0, 87) + '...' }
        [void]$sb.AppendLine(("| {0} | {1} | {2} | `{3}` | {4} | {5} | {6} |" -f $rank, $s.score, $u, $s.target, $s.lever, $s.tactic, $hyp))
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("_Breakthroughs come from volume + weird paths that still score. Parallel PRs implement survivors._")
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($leaders, $sb.ToString(), $utf8)

    # Event on blackboard
    try {
        Invoke-WpaiBlackboardRmw -Mutator {
            param($bb)
            Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'improve.generation' -Division 'software' -Actor 'bridge' -Refs @{
                generation = $genIdx
                survivors  = $Top
                catalog    = $catalog.Count
            }
        } | Out-Null
    } catch { }

    return [pscustomobject]@{
        generation    = $genIdx
        generation_path = $genPath
        leaders_path  = $leaders
        catalog_size  = $catalog.Count
        survivors     = $survivors.Count
        top_score     = if ($survivors.Count) { $survivors[0].score } else { 0 }
        top_id        = if ($survivors.Count) { $survivors[0].id } else { $null }
        top_hypothesis = if ($survivors.Count) { $survivors[0].hypothesis } else { $null }
    }
}

function Get-WpaiImproveLeaders {
    $rt = Get-WpaiImproveRuntimeDir
    $leaders = Join-Path $rt 'LEADERS.md'
    if (-not (Test-Path -LiteralPath $leaders)) {
        return 'No generation yet. Run: wpai improve generation'
    }
    return Get-Content -LiteralPath $leaders -Raw -Encoding utf8
}

function Export-WpaiImproveBriefs {
    param([int]$Top = 8)
    $rt = Get-WpaiImproveRuntimeDir
    $gens = @(Get-ChildItem -LiteralPath $rt -Filter 'generation-*.json' -File -ErrorAction SilentlyContinue | Sort-Object Name -Descending)
    if ($gens.Count -eq 0) { throw 'No generation found. Run: wpai improve generation' }
    $gen = Read-WpaiJsonFile -Path $gens[0].FullName
    $survivors = @($gen.survivors | Select-Object -First $Top)
    $briefDir = Join-Path $rt 'briefs'
    if (-not (Test-Path -LiteralPath $briefDir)) {
        New-Item -ItemType Directory -Force -Path $briefDir | Out-Null
    }
    # clear old briefs for this export
    Get-ChildItem -LiteralPath $briefDir -Filter 'brief-*.md' -ErrorAction SilentlyContinue | Remove-Item -Force
    $i = 0
    $paths = @()
    foreach ($s in $survivors) {
        $i++
        $name = 'brief-{0:D2}-{1}.md' -f $i, $s.id
        $bp = Join-Path $briefDir $name
        $body = @"
# Improve Path Brief $i — $($s.id)

**Generation:** $($gen.generation)  
**Score:** $($s.score) (prior $($s.prior_score))  
**Unconventional:** $($s.unconventional)

## Hypothesis
$($s.hypothesis)

## Coordinates
- **target:** ``$($s.target)``
- **lever:** ``$($s.lever)``
- **tactic:** ``$($s.tactic)``
- **invert:** ``$($s.invert)``
- **probe:** ``$($s.probe)``

## Agent instructions
1. Treat this as an *experiment*, not a sacred design. Implement the smallest slice that could falsify or support the hypothesis.
2. Prefer local tests / self-check / measurement over narrative.
3. If the path is wrong, **kill it fast** and document why in a short note under ``Workspace\.wpai\improve-swarm\kills\``.
4. If the path works, report: metric delta, files touched, residual risk.
5. Do **not** spend real money, publish, or bypass Janus validation for workload mutations.
6. Unconventional paths are encouraged — invert assumptions when ``invert`` is set.

## Fitness context
- fit: $($s.fit)
- novelty: $($s.novelty)
- measurable: $($s.measurable)
- probe_ok: $($s.probe_ok) ($($s.probe_detail))
- hits: $($s.hits -join ', ')

## Spawn
Hand this file to a subagent with write scope limited to the target area. Run many such agents in parallel on **different** path ids.
"@
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($bp, $body, $utf8)
        $paths += $bp
    }
    return [pscustomobject]@{ count = $paths.Count; paths = $paths; generation = $gen.generation }
}

function Invoke-WpaiImproveMutate {
    <#
    .SYNOPSIS
      Next-gen diversity: keep top survivors' "genes", inject fresh random paths into catalog.
    #>
    param([int]$Keep = 30, [int]$Inject = 80)
    $rt = Get-WpaiImproveRuntimeDir
    $gens = @(Get-ChildItem -LiteralPath $rt -Filter 'generation-*.json' -File | Sort-Object Name -Descending)
    if ($gens.Count -eq 0) { throw 'No generation to mutate from' }
    $gen = Read-WpaiJsonFile -Path $gens[0].FullName
    $survivors = @($gen.survivors | Select-Object -First $Keep)

    # Rebuild catalog: survivors as fixed seeds + new randoms
    $dim = Get-WpaiImproveDimensions
    $rng = [System.Random]::new([int](([DateTime]::UtcNow.Ticks) % [int]::MaxValue))
    $lines = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    foreach ($s in $survivors) {
        $seed = "$($s.target)|$($s.lever)|$($s.tactic)|$($s.invert)|$($s.probe)"
        $seen[$seed] = $true
        $obj = [ordered]@{
            schema_version  = '1.0.0'
            id              = $s.id
            target          = $s.target
            lever           = $s.lever
            tactic          = $s.tactic
            invert          = $s.invert
            probe           = $s.probe
            hypothesis      = $s.hypothesis
            unconventional  = $s.unconventional
            risk            = 'low'
            cost_to_try     = $s.cost_to_try
            status          = 'survivor'
            generation_born = $gen.generation
        }
        $lines.Add(($obj | ConvertTo-Json -Compress -Depth 6))
        # Mutate: one sibling with same target/lever, new tactic or invert
        $tac2 = $dim.tactics[$rng.Next($dim.tactics.Count)]
        $inv2 = $dim.inverts[$rng.Next($dim.inverts.Count)]
        $pr2 = $dim.probes[$rng.Next($dim.probes.Count)]
        $seed2 = "$($s.target)|$($s.lever)|$tac2|$inv2|$pr2"
        if (-not $seen.ContainsKey($seed2)) {
            $seen[$seed2] = $true
            $id2 = New-WpaiImprovePathId -Seed $seed2
            $hyp2 = New-WpaiImproveHypothesis -Target $s.target -Lever $s.lever -Tactic $tac2 -Invert $inv2 -Probe $pr2
            $m = [ordered]@{
                schema_version  = '1.0.0'
                id              = $id2
                target          = $s.target
                lever           = $s.lever
                tactic          = $tac2
                invert          = $inv2
                probe           = $pr2
                hypothesis      = $hyp2
                unconventional  = ($inv2 -ne 'none')
                risk            = 'low'
                cost_to_try     = 'cheap'
                status          = 'mutant'
                generation_born = ([int]$gen.generation + 1)
                parent_id       = $s.id
            }
            $lines.Add(($m | ConvertTo-Json -Compress -Depth 6))
        }
    }
    $guard = 0
    $targetCount = $lines.Count + $Inject
    while ($lines.Count -lt $targetCount -and $guard -lt 5000) {
        $guard++
        $t = $dim.targets[$rng.Next($dim.targets.Count)]
        $l = $dim.levers[$rng.Next($dim.levers.Count)]
        $tac = $dim.tactics[$rng.Next($dim.tactics.Count)]
        $inv = $dim.inverts[$rng.Next($dim.inverts.Count)]
        $pr = $dim.probes[$rng.Next($dim.probes.Count)]
        if ($rng.NextDouble() -gt 0.5) { $inv = $dim.inverts[$rng.Next($dim.inverts.Count)] } # higher invert rate in inject
        $seed = "$t|$l|$tac|$inv|$pr"
        if ($seen.ContainsKey($seed)) { continue }
        $seen[$seed] = $true
        $id = New-WpaiImprovePathId -Seed $seed
        $obj = [ordered]@{
            schema_version  = '1.0.0'
            id              = $id
            target          = $t
            lever           = $l
            tactic          = $tac
            invert          = $inv
            probe           = $pr
            hypothesis      = (New-WpaiImproveHypothesis -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr)
            unconventional  = ($inv -ne 'none')
            risk            = 'low'
            cost_to_try     = 'cheap'
            status          = 'inject'
            generation_born = ([int]$gen.generation + 1)
        }
        $lines.Add(($obj | ConvertTo-Json -Compress -Depth 6))
    }
    $catalog = Get-WpaiImproveCatalogPath
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($catalog, $lines, $utf8)
    return [pscustomobject]@{ catalog = $catalog; count = $lines.Count; from_generation = $gen.generation }
}
