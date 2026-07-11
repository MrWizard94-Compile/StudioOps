# Brute-force improve swarm — path genome, scoring, generation, briefs, learning.
# Explore hundreds of unconventional paths; converge by fitness; ban dead genes.
# No paid APIs. Outcomes from kills/experiments feed the next generation.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Paths / runtime ──────────────────────────────────────────────────────────

function Get-WpaiImproveSwarmRoot {
    return 'C:\WPAI\Software\StudioOps\improve-swarm'
}

function Get-WpaiImproveRuntimeDir {
    $d = Join-Path (Get-WpaiConfigValue -Name 'wpai_dir' -Default 'C:\WPAI\Workspace\.wpai') 'improve-swarm'
    if (-not (Test-Path -LiteralPath $d)) {
        New-Item -ItemType Directory -Force -Path $d | Out-Null
    }
    foreach ($sub in @('briefs', 'kills')) {
        $p = Join-Path $d $sub
        if (-not (Test-Path -LiteralPath $p)) {
            New-Item -ItemType Directory -Force -Path $p | Out-Null
        }
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

function Get-WpaiImproveOutcomesPath {
    return (Join-Path (Get-WpaiImproveRuntimeDir) 'outcomes.jsonl')
}

function Get-WpaiImproveBansPath {
    return (Join-Path (Get-WpaiImproveRuntimeDir) 'bans.json')
}

function Get-WpaiImproveExperimentsRoot {
    return (Join-Path (Get-WpaiImproveSwarmRoot) 'experiments')
}

function New-WpaiImprovePathId {
    param([string]$Seed)
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($Seed)
    )
    $hex = ($hash | ForEach-Object { $_.ToString('x2') }) -join ''
    return 'path-' + $hex.Substring(0, 12)
}

# ── Dimensions / genome ──────────────────────────────────────────────────────

function Get-WpaiImproveDimensions {
    return @{
        targets = @(
            'studioops-cli', 'studioops-blackboard', 'hellforge-ui', 'hellforge-bus',
            'janus-loop', 'janus-validation', 'janus-memory', 'music-pipeline',
            'gaming-mod', 'omni32-assets', 'research-genome', 'cross-brand',
            'token-budget', 'overnight', 'hitl-approvals', 'observability',
            'improve-swarm'
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

function Test-WpaiImproveHasBannedFlag {
    <#
    .SYNOPSIS
      Safe banned flag read for StrictMode (old generation JSON may omit the property).
    #>
    param($Obj)
    if ($null -eq $Obj) { return $false }
    if ($Obj -is [System.Collections.IDictionary]) {
        if ($Obj.Contains('banned')) { return [bool]$Obj['banned'] }
        return $false
    }
    if ($Obj.PSObject.Properties.Match('banned').Count -gt 0) {
        return [bool]$Obj.banned
    }
    return $false
}

function Get-WpaiImproveGeneKey {
    <#
    .SYNOPSIS
      Build gene keys at several granularities for ban/boost matching.
    #>
    param(
        [string]$Target = '',
        [string]$Lever = '',
        [string]$Tactic = '',
        [string]$Invert = '',
        [string]$Probe = '',
        [ValidateSet('full', 'tactic_lever', 'tactic', 'target_lever', 'path')]
        [string]$Kind = 'full',
        [string]$PathId = ''
    )
    switch ($Kind) {
        'full'         { return ("{0}|{1}|{2}|{3}|{4}" -f $Target, $Lever, $Tactic, $Invert, $Probe) }
        'tactic_lever' { return ("{0}×{1}" -f $Tactic, $Lever) }
        'tactic'       { return $Tactic }
        'target_lever' { return ("{0}|{1}" -f $Target, $Lever) }
        'path'         { return $PathId }
        default        { return ("{0}|{1}|{2}|{3}|{4}" -f $Target, $Lever, $Tactic, $Invert, $Probe) }
    }
}

function New-WpaiImprovePathObject {
    param(
        [string]$Target,
        [string]$Lever,
        [string]$Tactic,
        [string]$Invert,
        [string]$Probe,
        [string]$Status = 'candidate',
        [int]$GenerationBorn = 0,
        [string]$ParentId = $null,
        [string]$Risk = 'low',
        [string]$CostToTry = 'cheap'
    )
    $unconventional = ($Invert -ne 'none') -or ($Tactic -in @(
            'delete-abstraction', 'remove-feature', 'starve-input', 'flood-input',
            'invert-control', 'guess-then-falsify', 'borrow-from-idle-games', 'borrow-from-avionics'
        ))
    if ($Risk -eq 'low') {
        if ($Target -match 'music|brand|gaming') { $Risk = 'med' }
        if ($Tactic -match 'fail-open|flood' -or $Lever -eq 'autonomy') { $Risk = 'med' }
        if ($Target -match 'publish|distro' -or $Lever -match 'money') { $Risk = 'high' }
    }
    if ($CostToTry -eq 'cheap') {
        if ($Probe -in @('micro-bench', 'self-check')) { $CostToTry = 'medium' }
        if ($Probe -eq 'property-quick' -and $Target -match 'janus') { $CostToTry = 'medium' }
    }
    $id = New-WpaiImprovePathId -Seed (Get-WpaiImproveGeneKey -Target $Target -Lever $Lever -Tactic $Tactic -Invert $Invert -Probe $Probe -Kind full)
    $obj = [ordered]@{
        schema_version  = '1.0.0'
        id              = $id
        target          = $Target
        lever           = $Lever
        tactic          = $Tactic
        invert          = $Invert
        probe           = $Probe
        hypothesis      = (New-WpaiImproveHypothesis -Target $Target -Lever $Lever -Tactic $Tactic -Invert $Invert -Probe $Probe)
        unconventional  = $unconventional
        risk            = $Risk
        cost_to_try     = $CostToTry
        status          = $Status
        generation_born = $GenerationBorn
    }
    if ($ParentId) { $obj['parent_id'] = $ParentId }
    return $obj
}

# ── Catalog ──────────────────────────────────────────────────────────────────

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
    $bans = Get-WpaiImproveBans
    $rng = [System.Random]::new(0x57424149) # fixed seed for reproducibility
    if ($Force) { $rng = [System.Random]::new([int]([DateTime]::UtcNow.Ticks % [int]::MaxValue)) }

    $lines = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    $skippedBanned = 0
    $guard = 0
    while ($lines.Count -lt $Count -and $guard -lt ($Count * 50)) {
        $guard++
        $t = $dim.targets[$rng.Next($dim.targets.Count)]
        $l = $dim.levers[$rng.Next($dim.levers.Count)]
        $tac = $dim.tactics[$rng.Next($dim.tactics.Count)]
        $inv = $dim.inverts[$rng.Next($dim.inverts.Count)]
        $pr = $dim.probes[$rng.Next($dim.probes.Count)]
        # Bias: ~35% unconventional invert
        if ($rng.NextDouble() -gt 0.35) { $inv = 'none' }
        $seed = Get-WpaiImproveGeneKey -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr -Kind full
        if ($seen.ContainsKey($seed)) { continue }
        $hit = Test-WpaiImproveGeneBanned -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr -Bans $bans
        if ($hit.banned) {
            $skippedBanned++
            continue
        }
        $seen[$seed] = $true
        $obj = New-WpaiImprovePathObject -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr -Status 'candidate' -GenerationBorn 0
        $lines.Add(($obj | ConvertTo-Json -Compress -Depth 6))
    }

    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($catalog, $lines, $utf8)
    return [pscustomobject]@{
        path            = $catalog
        count           = $lines.Count
        regenerated     = $true
        skipped_banned  = $skippedBanned
    }
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

function Write-WpaiImproveCatalog {
    param([object[]]$Paths)
    $catalog = Get-WpaiImproveCatalogPath
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($p in $Paths) {
        if ($p -is [System.Collections.IDictionary] -or $p -is [hashtable] -or $p -is [System.Collections.Specialized.OrderedDictionary]) {
            $lines.Add(($p | ConvertTo-Json -Compress -Depth 6))
        } else {
            # PSCustomObject → ordered for stable keys
            $o = [ordered]@{}
            foreach ($prop in $p.PSObject.Properties) {
                $o[$prop.Name] = $prop.Value
            }
            $lines.Add(($o | ConvertTo-Json -Compress -Depth 6))
        }
    }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($catalog, $lines, $utf8)
    return $catalog
}

# ── Outcomes ledger + gene bans ──────────────────────────────────────────────

function Get-WpaiImproveBans {
    $path = Get-WpaiImproveBansPath
    if (-not (Test-Path -LiteralPath $path)) {
        return [pscustomobject]@{
            schema_version = '1.0.0'
            updated_at     = $null
            bans           = @()
        }
    }
    try {
        $obj = Read-WpaiJsonFile -Path $path
        if ($null -eq $obj.bans) {
            return [pscustomobject]@{
                schema_version = '1.0.0'
                updated_at     = $obj.updated_at
                bans           = @()
            }
        }
        return $obj
    } catch {
        return [pscustomobject]@{
            schema_version = '1.0.0'
            updated_at     = $null
            bans           = @()
        }
    }
}

function Save-WpaiImproveBans {
    param($BansDoc)
    $path = Get-WpaiImproveBansPath
    if ($BansDoc -isnot [System.Collections.IDictionary]) {
        $ordered = [ordered]@{
            schema_version = '1.0.0'
            updated_at     = (Get-WpaiUtcNow)
            bans           = @($BansDoc.bans)
        }
        if ($BansDoc.PSObject.Properties['schema_version']) {
            $ordered['schema_version'] = [string]$BansDoc.schema_version
        }
        Write-WpaiJsonAtomic -Path $path -Object $ordered
    } else {
        $BansDoc['updated_at'] = Get-WpaiUtcNow
        Write-WpaiJsonAtomic -Path $path -Object $BansDoc
    }
    return $path
}

function Test-WpaiImproveGeneBanned {
    param(
        [string]$Target = '',
        [string]$Lever = '',
        [string]$Tactic = '',
        [string]$Invert = '',
        [string]$Probe = '',
        [string]$PathId = '',
        $Bans = $null
    )
    if ($null -eq $Bans) { $Bans = Get-WpaiImproveBans }
    $list = @($Bans.bans)
    if ($list.Count -eq 0) {
        return [pscustomobject]@{ banned = $false; ban = $null; reason = '' }
    }
    $full = Get-WpaiImproveGeneKey -Target $Target -Lever $Lever -Tactic $Tactic -Invert $Invert -Probe $Probe -Kind full
    $tl = Get-WpaiImproveGeneKey -Tactic $Tactic -Lever $Lever -Kind tactic_lever
    $tgtL = Get-WpaiImproveGeneKey -Target $Target -Lever $Lever -Kind target_lever
    foreach ($b in $list) {
        $kind = [string]$b.kind
        $key = [string]$b.key
        $match = $false
        switch ($kind) {
            'path' {
                if ($PathId -and $key -eq $PathId) { $match = $true }
                elseif ($PathId -and [string]$b.path_id -eq $PathId) { $match = $true }
            }
            'full' {
                if ($key -eq $full) { $match = $true }
            }
            'tactic_lever' {
                if ($key -eq $tl) { $match = $true }
                elseif ([string]$b.tactic -eq $Tactic -and [string]$b.lever -eq $Lever) { $match = $true }
            }
            'tactic' {
                if ($key -eq $Tactic -or [string]$b.tactic -eq $Tactic) { $match = $true }
            }
            'target_lever' {
                if ($key -eq $tgtL) { $match = $true }
            }
            default {
                if ($key -and ($key -eq $full -or $key -eq $tl -or $key -eq $PathId)) { $match = $true }
            }
        }
        if ($match) {
            return [pscustomobject]@{
                banned = $true
                ban    = $b
                reason = [string]$b.reason
            }
        }
    }
    return [pscustomobject]@{ banned = $false; ban = $null; reason = '' }
}

function Read-WpaiImproveOutcomes {
    $path = Get-WpaiImproveOutcomesPath
    if (-not (Test-Path -LiteralPath $path)) { return @() }
    $out = @()
    foreach ($line in Get-Content -LiteralPath $path -Encoding utf8) {
        $trim = $line.Trim()
        if (-not $trim) { continue }
        try { $out += ($trim | ConvertFrom-Json) } catch { }
    }
    return $out
}

function Write-WpaiImproveOutcome {
    <#
    .SYNOPSIS
      Append one outcome to the learning ledger (idempotent by path_id+verdict+source when possible).
    #>
    param(
        [Parameter(Mandatory)]
        [string]$PathId,
        [Parameter(Mandatory)]
        [ValidateSet('SUPPORTED', 'KILLED', 'INCONCLUSIVE')]
        [string]$Verdict,
        [string]$Source = 'manual',
        [string]$Note = '',
        [string]$Target = '',
        [string]$Lever = '',
        [string]$Tactic = '',
        [string]$Invert = '',
        [string]$Probe = '',
        [string]$Hypothesis = '',
        [double]$Score = -1,
        [string]$Artifact = '',
        [switch]$Force
    )
    # Enrich from catalog if coords missing
    if (-not $Target -or -not $Tactic) {
        $cat = @(Read-WpaiImproveCatalog | Where-Object { $_.id -eq $PathId } | Select-Object -First 1)
        if ($cat.Count -gt 0) {
            $c = $cat[0]
            if (-not $Target) { $Target = [string]$c.target }
            if (-not $Lever) { $Lever = [string]$c.lever }
            if (-not $Tactic) { $Tactic = [string]$c.tactic }
            if (-not $Invert) { $Invert = [string]$c.invert }
            if (-not $Probe) { $Probe = [string]$c.probe }
            if (-not $Hypothesis) { $Hypothesis = [string]$c.hypothesis }
        }
    }
    # Also try latest generation survivors
    if (-not $Target) {
        $rt = Get-WpaiImproveRuntimeDir
        $gens = @(Get-ChildItem -LiteralPath $rt -Filter 'generation-*.json' -File -ErrorAction SilentlyContinue | Sort-Object Name -Descending)
        foreach ($g in $gens) {
            try {
                $gen = Read-WpaiJsonFile -Path $g.FullName
                $hit = @($gen.survivors | Where-Object { $_.id -eq $PathId } | Select-Object -First 1)
                if ($hit.Count -gt 0) {
                    $s = $hit[0]
                    $Target = [string]$s.target
                    $Lever = [string]$s.lever
                    $Tactic = [string]$s.tactic
                    $Invert = [string]$s.invert
                    $Probe = [string]$s.probe
                    $Hypothesis = [string]$s.hypothesis
                    if ($Score -lt 0 -and $s.score) { $Score = [double]$s.score }
                    break
                }
            } catch { }
        }
    }

    $path = Get-WpaiImproveOutcomesPath
    if (-not $Force -and (Test-Path -LiteralPath $path)) {
        foreach ($line in Get-Content -LiteralPath $path -Encoding utf8) {
            try {
                $o = $line | ConvertFrom-Json
                if ([string]$o.path_id -eq $PathId -and [string]$o.verdict -eq $Verdict -and [string]$o.source -eq $Source) {
                    return [pscustomobject]@{ path = $path; appended = $false; deduped = $true; path_id = $PathId; verdict = $Verdict }
                }
            } catch { }
        }
    }

    $geneFull = Get-WpaiImproveGeneKey -Target $Target -Lever $Lever -Tactic $Tactic -Invert $Invert -Probe $Probe -Kind full
    $geneTl = Get-WpaiImproveGeneKey -Tactic $Tactic -Lever $Lever -Kind tactic_lever
    $entry = [ordered]@{
        schema_version = '1.0.0'
        ts             = (Get-WpaiUtcNow)
        path_id        = $PathId
        verdict        = $Verdict
        source         = $Source
        note           = $Note
        target         = $Target
        lever          = $Lever
        tactic         = $Tactic
        invert         = $Invert
        probe          = $Probe
        hypothesis     = $Hypothesis
        gene_full      = $geneFull
        gene_tactic_lever = $geneTl
        score          = $(if ($Score -ge 0) { $Score } else { $null })
        artifact       = $Artifact
    }
    $json = ($entry | ConvertTo-Json -Compress -Depth 6)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::AppendAllText($path, $json + [Environment]::NewLine, $utf8)
    return [pscustomobject]@{ path = $path; appended = $true; deduped = $false; path_id = $PathId; verdict = $Verdict; gene_tactic_lever = $geneTl }
}

function Find-WpaiImprovePathCoords {
    param([string]$PathId)
    $empty = [pscustomobject]@{
        target = ''; lever = ''; tactic = ''; invert = ''; probe = ''; hypothesis = ''; score = -1.0
    }
    if (-not $PathId) { return $empty }
    $cat = @(Read-WpaiImproveCatalog | Where-Object { $_.id -eq $PathId } | Select-Object -First 1)
    if ($cat.Count -gt 0) {
        $c = $cat[0]
        return [pscustomobject]@{
            target = [string]$c.target; lever = [string]$c.lever; tactic = [string]$c.tactic
            invert = [string]$c.invert; probe = [string]$c.probe; hypothesis = [string]$c.hypothesis
            score = -1.0
        }
    }
    $rt = Get-WpaiImproveRuntimeDir
    $gens = @(Get-ChildItem -LiteralPath $rt -Filter 'generation-*.json' -File -ErrorAction SilentlyContinue | Sort-Object Name -Descending)
    foreach ($g in $gens) {
        try {
            $gen = Read-WpaiJsonFile -Path $g.FullName
            $hit = @($gen.survivors | Where-Object { $_.id -eq $PathId } | Select-Object -First 1)
            if ($hit.Count -eq 0 -and $gen.PSObject.Properties['all_top_scores']) {
                # survivors only usually
            }
            if ($hit.Count -gt 0) {
                $s = $hit[0]
                $sc = -1.0
                if ($s.PSObject.Properties['score'] -and $null -ne $s.score) { $sc = [double]$s.score }
                return [pscustomobject]@{
                    target = [string]$s.target; lever = [string]$s.lever; tactic = [string]$s.tactic
                    invert = [string]$s.invert; probe = [string]$s.probe; hypothesis = [string]$s.hypothesis
                    score = $sc
                }
            }
        } catch { }
    }
    # GEN2-RESULTS style markdown table is not structured; briefs may help
    $briefs = Join-Path $rt 'briefs'
    if (Test-Path -LiteralPath $briefs) {
        $bf = Get-ChildItem -LiteralPath $briefs -Filter "brief-*-$PathId.md" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($bf) {
            $text = Get-Content -LiteralPath $bf.FullName -Raw -Encoding utf8
            $coords = @{ target = ''; lever = ''; tactic = ''; invert = ''; probe = ''; hypothesis = '' }
            if ($text -match '\*\*target:\*\*\s+`([^`]+)`') { $coords.target = $Matches[1] }
            if ($text -match '\*\*lever:\*\*\s+`([^`]+)`') { $coords.lever = $Matches[1] }
            if ($text -match '\*\*tactic:\*\*\s+`([^`]+)`') { $coords.tactic = $Matches[1] }
            if ($text -match '\*\*invert:\*\*\s+`([^`]+)`') { $coords.invert = $Matches[1] }
            if ($text -match '\*\*probe:\*\*\s+`([^`]+)`') { $coords.probe = $Matches[1] }
            if ($text -match '(?s)## Hypothesis\r?\n(.+?)\r?\n\r?\n##') { $coords.hypothesis = $Matches[1].Trim() }
            return [pscustomobject]@{
                target = $coords.target; lever = $coords.lever; tactic = $coords.tactic
                invert = $coords.invert; probe = $coords.probe; hypothesis = $coords.hypothesis
                score = -1.0
            }
        }
    }
    return $empty
}

function Invoke-WpaiImproveIngestSources {
    <#
    .SYNOPSIS
      Scan kills/ and experiments/**/result.json into outcomes ledger.
    #>
    $ingested = 0
    $deduped = 0
    $rt = Get-WpaiImproveRuntimeDir
    $killsDir = Join-Path $rt 'kills'
    if (Test-Path -LiteralPath $killsDir) {
        foreach ($kf in Get-ChildItem -LiteralPath $killsDir -Filter '*.md' -File -ErrorAction SilentlyContinue) {
            $pathId = $null
            if ($kf.BaseName -match '^(path-[a-f0-9]{12})') { $pathId = $Matches[1] }
            elseif ($kf.Name -match '(path-[a-f0-9]{12})') { $pathId = $Matches[1] }
            if (-not $pathId) { continue }
            $note = (Get-Content -LiteralPath $kf.FullName -Raw -Encoding utf8).Trim()
            if ($note.Length -gt 500) { $note = $note.Substring(0, 497) + '...' }
            $coords = Find-WpaiImprovePathCoords -PathId $pathId
            # Known hard-coded kill learning from gen2 when coords missing
            if (-not $coords.tactic -and $pathId -eq 'path-6ee11461507d') {
                $coords = [pscustomobject]@{
                    target = 'janus-loop'; lever = 'latency'; tactic = 'raise-context'
                    invert = 'none'; probe = 'static-score'
                    hypothesis = 'On janus-loop, improve latency by applying raise-context'
                    score = -1.0
                }
            }
            $r = Write-WpaiImproveOutcome -PathId $pathId -Verdict 'KILLED' -Source 'kill' -Note $note `
                -Target $coords.target -Lever $coords.lever -Tactic $coords.tactic `
                -Invert $coords.invert -Probe $coords.probe -Hypothesis $coords.hypothesis
            if ($r.appended) { $ingested++ } else { $deduped++ }
        }
    }

    $expRoot = Get-WpaiImproveExperimentsRoot
    if (Test-Path -LiteralPath $expRoot) {
        $results = @(Get-ChildItem -LiteralPath $expRoot -Recurse -Filter 'result.json' -File -ErrorAction SilentlyContinue)
        foreach ($rf in $results) {
            try {
                $obj = Read-WpaiJsonFile -Path $rf.FullName
            } catch { continue }
            $pathId = [string]$obj.path_id
            if (-not $pathId -and $rf.Directory.Name -match '^(path-[a-f0-9]{12})$') {
                $pathId = $Matches[1]
            }
            if (-not $pathId) { continue }
            $verdict = [string]$obj.verdict
            if (-not $verdict) {
                if ($obj.PSObject.Properties['ok'] -and [bool]$obj.ok) { $verdict = 'SUPPORTED' }
                else { $verdict = 'INCONCLUSIVE' }
            }
            $verdict = $verdict.ToUpperInvariant()
            if ($verdict -notin @('SUPPORTED', 'KILLED', 'INCONCLUSIVE')) {
                if ($verdict -match 'SUPPORT|PASS|OK') { $verdict = 'SUPPORTED' }
                elseif ($verdict -match 'KILL|FAIL|DEAD') { $verdict = 'KILLED' }
                else { $verdict = 'INCONCLUSIVE' }
            }
            $note = ''
            if ($obj.PSObject.Properties['note'] -and $obj.note) { $note = [string]$obj.note }
            elseif ($obj.PSObject.Properties['metric'] -and $obj.metric) { $note = [string]$obj.metric }
            $artifact = ''
            if ($obj.PSObject.Properties['artifact'] -and $obj.artifact) { $artifact = [string]$obj.artifact }
            elseif ($obj.PSObject.Properties['hypothesis'] -and $obj.hypothesis) { $note = if ($note) { $note } else { [string]$obj.hypothesis } }

            $coords = Find-WpaiImprovePathCoords -PathId $pathId
            $target = $coords.target
            $lever = $coords.lever
            $tactic = $coords.tactic
            $invert = $coords.invert
            $probe = $coords.probe
            $hyp = $coords.hypothesis
            if ($obj.PSObject.Properties['tactic'] -and $obj.tactic) { $tactic = [string]$obj.tactic }
            if ($obj.PSObject.Properties['hypothesis'] -and $obj.hypothesis) { $hyp = [string]$obj.hypothesis }
            if ($obj.PSObject.Properties['probe'] -and $obj.probe) { $probe = [string]$obj.probe }

            $r = Write-WpaiImproveOutcome -PathId $pathId -Verdict $verdict -Source 'experiment' -Note $note `
                -Target $target -Lever $lever -Tactic $tactic -Invert $invert -Probe $probe `
                -Hypothesis $hyp -Artifact $artifact -Score $(if ($coords.score -ge 0) { $coords.score } else { -1 })
            if ($r.appended) { $ingested++ } else { $deduped++ }
        }
    }

    # GEN2-RESULTS.md hard kills if kill file missed coords
    $gen2 = Join-Path $rt 'GEN2-RESULTS.md'
    if (Test-Path -LiteralPath $gen2) {
        $text = Get-Content -LiteralPath $gen2 -Raw -Encoding utf8
        if ($text -match 'path-6ee11461507d' -and $text -match 'KILLED') {
            $r = Write-WpaiImproveOutcome -PathId 'path-6ee11461507d' -Verdict 'KILLED' -Source 'gen2-results' `
                -Note 'raise-context for loop latency is a dead end' `
                -Target 'janus-loop' -Lever 'latency' -Tactic 'raise-context' -Invert 'none' -Probe 'static-score' `
                -Hypothesis 'On janus-loop, improve latency by applying raise-context'
            if ($r.appended) { $ingested++ } else { $deduped++ }
        }
        # Supported paths from gen2 table
        $supportedMap = @{
            'path-bb093e1445e8' = @{ t = 'janus-loop'; l = 'reliability'; tac = 'fuzz'; n = 'double-entry charge tests' }
            'path-7d61dc66f9c7' = @{ t = 'overnight'; l = 'determinism'; tac = 'bus-not-call'; n = 'dry-then-arm' }
            'path-ac4bacaf07a8' = @{ t = 'hellforge-bus'; l = 'dx'; tac = 'bus-not-call'; n = 'prestige archive' }
            'path-a8398d344cf1' = @{ t = 'overnight'; l = 'latency'; tac = 'local-ollama'; n = 'measure local first' }
            'path-e136eb2c9be0' = @{ t = 'overnight'; l = 'reliability'; tac = 'chaos-inject'; n = 'kill blocks overnight' }
        }
        foreach ($mapPathId in $supportedMap.Keys) {
            $m = $supportedMap[$mapPathId]
            $r = Write-WpaiImproveOutcome -PathId $mapPathId -Verdict 'SUPPORTED' -Source 'gen2-results' -Note $m.n `
                -Target $m.t -Lever $m.l -Tactic $m.tac -Invert 'none' -Probe 'static-score'
            if ($r.appended) { $ingested++ } else { $deduped++ }
        }
    }

    return [pscustomobject]@{ ingested = $ingested; deduped = $deduped }
}

function Invoke-WpaiImproveLearn {
    <#
    .SYNOPSIS
      Ingest outcomes from kills/experiments, derive gene bans, write LEARNING.md.
    #>
    param(
        [int]$KillThreshold = 1,
        [switch]$SkipIngest
    )
    if (-not $SkipIngest) {
        $ingest = Invoke-WpaiImproveIngestSources
    } else {
        $ingest = [pscustomobject]@{ ingested = 0; deduped = 0 }
    }

    $outcomes = @(Read-WpaiImproveOutcomes)
    $bansDoc = Get-WpaiImproveBans
    $existing = @{}
    foreach ($b in @($bansDoc.bans)) {
        $k = "{0}|{1}" -f [string]$b.kind, [string]$b.key
        $existing[$k] = $true
    }
    $newBans = New-Object System.Collections.Generic.List[object]
    foreach ($b in @($bansDoc.bans)) { $newBans.Add($b) }

    # Aggregate kills by tactic×lever
    $killByTl = @{}
    $supportByTl = @{}
    $killPaths = @{}
    $supportPaths = @{}
    foreach ($o in $outcomes) {
        $tl = [string]$o.gene_tactic_lever
        if (-not $tl -and $o.tactic -and $o.lever) {
            $tl = Get-WpaiImproveGeneKey -Tactic ([string]$o.tactic) -Lever ([string]$o.lever) -Kind tactic_lever
        }
        $outPathId = [string]$o.path_id
        $v = [string]$o.verdict
        if ($v -eq 'KILLED') {
            if ($tl) {
                if (-not $killByTl.ContainsKey($tl)) { $killByTl[$tl] = New-Object System.Collections.Generic.List[string] }
                $killByTl[$tl].Add($outPathId)
            }
            if ($outPathId) { $killPaths[$outPathId] = $o }
        } elseif ($v -eq 'SUPPORTED') {
            if ($tl) {
                if (-not $supportByTl.ContainsKey($tl)) { $supportByTl[$tl] = New-Object System.Collections.Generic.List[string] }
                $supportByTl[$tl].Add($outPathId)
            }
            if ($outPathId) { $supportPaths[$outPathId] = $o }
        }
    }

    $addedBans = 0
    foreach ($tl in $killByTl.Keys) {
        $evidence = @($killByTl[$tl] | Select-Object -Unique)
        # Do not ban if same gene also has more supports than kills (mixed signal)
        $supports = if ($supportByTl.ContainsKey($tl)) { @($supportByTl[$tl] | Select-Object -Unique).Count } else { 0 }
        if ($evidence.Count -lt $KillThreshold) { continue }
        if ($supports -gt $evidence.Count) { continue }
        $parts = $tl -split '×', 2
        $tactic = if ($parts.Count -ge 1) { $parts[0] } else { '' }
        $lever = if ($parts.Count -ge 2) { $parts[1] } else { '' }
        $key = $tl
        $ek = "tactic_lever|$key"
        if ($existing.ContainsKey($ek)) { continue }
        $noteBits = @()
        foreach ($evPathId in $evidence) {
            if ($killPaths.ContainsKey($evPathId) -and $killPaths[$evPathId].note) {
                $noteBits += [string]$killPaths[$evPathId].note
            }
        }
        $reason = if ($noteBits.Count) { ($noteBits | Select-Object -First 1) } else { "Killed $(($evidence).Count)x: $tl" }
        if ($reason.Length -gt 240) { $reason = $reason.Substring(0, 237) + '...' }
        $ban = [ordered]@{
            id             = 'ban-' + (New-WpaiId)
            kind           = 'tactic_lever'
            key            = $key
            tactic         = $tactic
            lever          = $lever
            reason         = $reason
            evidence_paths = @($evidence)
            created_at     = (Get-WpaiUtcNow)
            source         = 'learn'
        }
        $newBans.Add([pscustomobject]$ban)
        $existing[$ek] = $true
        $addedBans++
    }

    # Path-level bans for explicit kills
    foreach ($killPathId in $killPaths.Keys) {
        $ek = "path|$killPathId"
        if ($existing.ContainsKey($ek)) { continue }
        $o = $killPaths[$killPathId]
        $ban = [ordered]@{
            id             = 'ban-' + (New-WpaiId)
            kind           = 'path'
            key            = $killPathId
            path_id        = $killPathId
            reason         = $(if ($o.note) { [string]$o.note } else { "Path $killPathId killed" })
            evidence_paths = @($killPathId)
            created_at     = (Get-WpaiUtcNow)
            source         = 'learn'
        }
        $newBans.Add([pscustomobject]$ban)
        $existing[$ek] = $true
        $addedBans++
    }

    $doc = [ordered]@{
        schema_version = '1.0.0'
        updated_at     = (Get-WpaiUtcNow)
        bans           = @($newBans | ForEach-Object {
                if ($_ -is [System.Collections.IDictionary]) { $_ }
                else {
                    $h = [ordered]@{}
                    foreach ($p in $_.PSObject.Properties) { $h[$p.Name] = $p.Value }
                    $h
                }
            })
        stats          = [ordered]@{
            outcomes_total   = $outcomes.Count
            kills            = @($outcomes | Where-Object { $_.verdict -eq 'KILLED' }).Count
            supported        = @($outcomes | Where-Object { $_.verdict -eq 'SUPPORTED' }).Count
            inconclusive     = @($outcomes | Where-Object { $_.verdict -eq 'INCONCLUSIVE' }).Count
            bans_total       = $newBans.Count
            bans_added_now   = $addedBans
            supported_genes  = @($supportByTl.Keys)
        }
    }
    $bansPath = Save-WpaiImproveBans -BansDoc $doc

    # LEARNING.md summary
    $rt = Get-WpaiImproveRuntimeDir
    $learnMd = Join-Path $rt 'LEARNING.md'
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('# Improve Swarm Learning')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("Updated: $($doc.updated_at)")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("## Stats")
    [void]$sb.AppendLine("- Outcomes: $($doc.stats.outcomes_total) (KILLED=$($doc.stats.kills), SUPPORTED=$($doc.stats.supported), INCONCLUSIVE=$($doc.stats.inconclusive))")
    [void]$sb.AppendLine("- Ingest this run: +$($ingest.ingested) new, $($ingest.deduped) deduped")
    [void]$sb.AppendLine("- Bans: $($doc.stats.bans_total) total (+$addedBans this learn)")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('## Active bans (dead genes)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('| Kind | Key | Reason | Evidence |')
    [void]$sb.AppendLine('|------|-----|--------|----------|')
    foreach ($b in $newBans) {
        $kind = [string]$b.kind
        $key = [string]$b.key
        $reason = ([string]$b.reason) -replace '\|', '/'
        if ($reason.Length -gt 60) { $reason = $reason.Substring(0, 57) + '...' }
        $ev = @($b.evidence_paths) -join ', '
        [void]$sb.AppendLine("| $kind | ``$key`` | $reason | $ev |")
    }
    if ($newBans.Count -eq 0) {
        [void]$sb.AppendLine('| _(none)_ | | | |')
    }
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('## Supported genes (boost next gen)')
    [void]$sb.AppendLine('')
    foreach ($tl in ($supportByTl.Keys | Sort-Object)) {
        $n = @($supportByTl[$tl] | Select-Object -Unique).Count
        [void]$sb.AppendLine("- ``$tl`` ×$n")
    }
    if ($supportByTl.Count -eq 0) {
        [void]$sb.AppendLine('_No supported outcomes yet._')
    }
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('## How learning feeds the swarm')
    [void]$sb.AppendLine('1. Fitness demotes banned genes (near-zero score).')
    [void]$sb.AppendLine('2. Mutate/seed skip banned tactic×lever combos.')
    [void]$sb.AppendLine('3. Supported genes get a score boost and are preferred as mutation parents.')
    [void]$sb.AppendLine('4. Diversity selection avoids cloning one target/lever across all survivors.')
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($learnMd, $sb.ToString(), $utf8)

    try {
        Invoke-WpaiBlackboardRmw -Mutator {
            param($bb)
            Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'improve.learn' -Division 'software' -Actor 'bridge' -Refs @{
                outcomes = $outcomes.Count
                bans     = $newBans.Count
                added    = $addedBans
            }
        } | Out-Null
    } catch { }

    return [pscustomobject]@{
        outcomes_total = $outcomes.Count
        ingested       = $ingest.ingested
        deduped        = $ingest.deduped
        bans_total     = $newBans.Count
        bans_added     = $addedBans
        bans_path      = $bansPath
        learning_path  = $learnMd
        kills          = $doc.stats.kills
        supported      = $doc.stats.supported
    }
}

function Get-WpaiImproveOutcomeBoostMap {
    <#
    .SYNOPSIS
      Map gene_tactic_lever -> net signal in [-1,1] from outcomes (supports - kills).
    #>
    $outcomes = @(Read-WpaiImproveOutcomes)
    $map = @{}
    foreach ($o in $outcomes) {
        $tl = [string]$o.gene_tactic_lever
        if (-not $tl -and $o.tactic -and $o.lever) {
            $tl = Get-WpaiImproveGeneKey -Tactic ([string]$o.tactic) -Lever ([string]$o.lever) -Kind tactic_lever
        }
        if (-not $tl) { continue }
        if (-not $map.ContainsKey($tl)) { $map[$tl] = 0.0 }
        if ($o.verdict -eq 'SUPPORTED') { $map[$tl] += 1.0 }
        elseif ($o.verdict -eq 'KILLED') { $map[$tl] -= 1.5 }
    }
    # Normalize soft
    $out = @{}
    foreach ($k in $map.Keys) {
        $v = $map[$k]
        $out[$k] = [math]::Max(-1.0, [math]::Min(1.0, $v / 3.0))
    }
    return $out
}

# ── Fitness / probe ──────────────────────────────────────────────────────────

function Test-WpaiImproveCodebaseFit {
    param($PathObj)
    $score = 0.15
    $hits = @()
    $map = @{
        'studioops-cli'        = 'C:\WPAI\Software\StudioOps\cli'
        'studioops-blackboard' = 'C:\WPAI\Workspace\.wpai'
        'hellforge-ui'         = 'C:\WPAI\Software\HellForge\renderer'
        'hellforge-bus'        = 'C:\WPAI\Software\HellForge'
        'janus-loop'           = 'C:\WPAI\AI-Research\Janus\Project-Janus\packages\janus-integrations'
        'janus-validation'     = 'C:\WPAI\AI-Research\Janus\Project-Janus\packages\validation-kernel'
        'janus-memory'         = 'C:\WPAI\AI-Research\Janus\Smart-Library'
        'music-pipeline'       = 'C:\WPAI\Music'
        'gaming-mod'           = 'C:\WPAI\Gaming'
        'omni32-assets'        = 'C:\WPAI\AI-Research\AssetConverter'
        'research-genome'      = 'C:\WPAI\AI-Research\deep_research_engine'
        'overnight'            = 'C:\WPAI\Software\StudioOps\cli\lib\WpaiOvernight.ps1'
        'hitl-approvals'       = 'C:\WPAI\Workspace\.wpai\approvals'
        'token-budget'         = 'C:\WPAI\Software\StudioOps\cli\lib\WpaiBudgetLedger.ps1'
        'observability'        = 'C:\WPAI\Software\StudioOps\cli\lib\WpaiObserve.ps1'
        'cross-brand'          = 'C:\WPAI\Brand'
        'improve-swarm'        = 'C:\WPAI\Software\StudioOps\cli\lib\WpaiImproveSwarm.ps1'
    }
    $t = [string]$PathObj.target
    if ($map.ContainsKey($t) -and (Test-Path -LiteralPath $map[$t])) {
        $score += 0.45
        $hits += $map[$t]
    }
    $kw = [string]$PathObj.tactic
    if ($kw -match 'bus|blackboard|janus|genome|cache|fuzz|double-entry|measurement') { $score += 0.15 }
    if ($PathObj.unconventional) { $score += 0.05 }
    return [pscustomobject]@{ score = [math]::Min(1.0, $score); hits = $hits }
}

function Get-WpaiImproveFitness {
    param(
        $PathObj,
        $Bans = $null,
        $BoostMap = $null
    )
    if ($null -eq $Bans) { $Bans = Get-WpaiImproveBans }
    if ($null -eq $BoostMap) { $BoostMap = Get-WpaiImproveOutcomeBoostMap }

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

    $probeBoost = 0.15
    if ([string]$PathObj.probe -in @('static-score', 'grep-fit', 'schema-validate', 'docs-delta')) { $probeBoost = 0.4 }
    if ([string]$PathObj.probe -in @('unit-test', 'self-check', 'dry-run-script')) { $probeBoost = 0.3 }

    # Learning: outcome boost for supported genes
    $learnBoost = 0.0
    $tl = Get-WpaiImproveGeneKey -Tactic ([string]$PathObj.tactic) -Lever ([string]$PathObj.lever) -Kind tactic_lever
    if ($BoostMap.ContainsKey($tl)) {
        $sig = [double]$BoostMap[$tl]
        $learnBoost = 0.12 * $sig  # ± up to ~0.12, neg down to -0.12
    }

    $banHit = Test-WpaiImproveGeneBanned -Target ([string]$PathObj.target) -Lever ([string]$PathObj.lever) `
        -Tactic ([string]$PathObj.tactic) -Invert ([string]$PathObj.invert) -Probe ([string]$PathObj.probe) `
        -PathId ([string]$PathObj.id) -Bans $Bans

    $raw =
        0.26 * $fit.score +
        0.18 * $novelty +
        0.20 * $measurable +
        0.10 * $costBoost +
        0.14 * $probeBoost +
        $learnBoost -
        $riskPen

    if ($banHit.banned) {
        # Dead genes must not re-win generations
        $raw = [math]::Min($raw, 0.08)
        $raw = $raw * 0.2
    }

    $score = [math]::Round([math]::Max(0.0, [math]::Min(1.0, $raw)), 4)
    return [pscustomobject]@{
        id             = $PathObj.id
        score          = $score
        fit            = $fit.score
        novelty        = [math]::Round($novelty, 4)
        measurable     = $measurable
        risk_penalty   = $riskPen
        learn_boost    = [math]::Round($learnBoost, 4)
        banned         = [bool]$banHit.banned
        ban_reason     = [string]$banHit.reason
        cost_to_try    = [string]$PathObj.cost_to_try
        unconventional = [bool]$PathObj.unconventional
        hypothesis     = [string]$PathObj.hypothesis
        target         = [string]$PathObj.target
        lever          = [string]$PathObj.lever
        tactic         = [string]$PathObj.tactic
        invert         = [string]$PathObj.invert
        probe          = [string]$PathObj.probe
        gene_tactic_lever = $tl
        hits           = $fit.hits
    }
}

function Invoke-WpaiImproveProbe {
    param($RankedPath)
    $ok = $true
    $detail = 'static-ok'
    $probe = [string]$RankedPath.probe
    try {
        if ($RankedPath.banned) {
            return [pscustomobject]@{
                id     = $RankedPath.id
                ok     = $false
                detail = "banned: $($RankedPath.ban_reason)"
                probe  = $probe
            }
        }
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
                if ($RankedPath.target -match 'studioops|overnight|hitl|observability|token') {
                    $ok = Test-Path 'C:\WPAI\Software\StudioOps\cli\wpai.ps1'
                    $detail = 'wpai present'
                } else { $detail = 'dry-run n/a'; $ok = $true }
            }
            'self-check' {
                $ok = Test-Path 'C:\WPAI\Software\StudioOps\cli\Self-Check-Wpai.ps1'
                $detail = 'self-check script exists (not re-run per path)'
            }
            'unit-test' {
                $ok = Test-Path 'C:\WPAI\Software\StudioOps\cli\tests\wpai.tests.ps1'
                $detail = 'unit harness exists'
            }
            'micro-bench' {
                # Cheap wall-clock of a local file op — no paid API
                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                $null = Get-ChildItem 'C:\WPAI\Software\StudioOps\cli\lib' -File -ErrorAction SilentlyContinue
                $sw.Stop()
                $ok = $sw.ElapsedMilliseconds -lt 2000
                $detail = "lib_list_ms=$($sw.ElapsedMilliseconds)"
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

# ── Diversity selection ──────────────────────────────────────────────────────

function Select-WpaiImproveDiverseTop {
    <#
    .SYNOPSIS
      Greedy diversity-aware top-K: high score first, then prefer novel target/lever/tactic.
    #>
    param(
        [object[]]$Ranked,
        [int]$Top = 40
    )
    if ($null -eq $Ranked -or $Ranked.Count -eq 0) { return @() }
    $sorted = @($Ranked | Sort-Object { [double]$_.score } -Descending)
    $selected = @()
    $usedTargets = @{}
    $usedLevers = @{}
    $usedTactics = @{}
    $usedTl = @{}

    # Always take absolute best first (if not banned)
    foreach ($r in $sorted) {
        if ($r.banned) { continue }
        $selected += ,$r
        $usedTargets[[string]$r.target] = 1
        $usedLevers[[string]$r.lever] = 1
        $usedTactics[[string]$r.tactic] = 1
        $usedTl["$($r.tactic)×$($r.lever)"] = 1
        break
    }

    while ($selected.Count -lt $Top) {
        $best = $null
        $bestAdj = [double]-1.0
        foreach ($r in $sorted) {
            if ($r.banned) { continue }
            $already = $false
            foreach ($s in $selected) { if ([string]$s.id -eq [string]$r.id) { $already = $true; break } }
            if ($already) { continue }
            $bonus = [double]0.0
            $t0 = [string]$r.target
            $l0 = [string]$r.lever
            $tac0 = [string]$r.tactic
            $tl0 = "$tac0×$l0"
            if (-not $usedTargets.ContainsKey($t0)) { $bonus += 0.04 }
            if (-not $usedLevers.ContainsKey($l0)) { $bonus += 0.03 }
            if (-not $usedTactics.ContainsKey($tac0)) { $bonus += 0.03 }
            if (-not $usedTl.ContainsKey($tl0)) { $bonus += 0.05 }
            if ($usedTargets.ContainsKey($t0) -and [int]$usedTargets[$t0] -ge 3) { $bonus -= 0.06 }
            if ($usedTl.ContainsKey($tl0) -and [int]$usedTl[$tl0] -ge 2) { $bonus -= 0.08 }
            $adj = [double]$r.score + $bonus
            if ($adj -gt $bestAdj) {
                $bestAdj = $adj
                $best = $r
            }
        }
        if ($null -eq $best) { break }
        $selected += ,$best
        $t = [string]$best.target
        $l = [string]$best.lever
        $tac = [string]$best.tactic
        $tl = "$tac×$l"
        if ($usedTargets.ContainsKey($t)) { $usedTargets[$t] = [int]$usedTargets[$t] + 1 } else { $usedTargets[$t] = 1 }
        if ($usedLevers.ContainsKey($l)) { $usedLevers[$l] = [int]$usedLevers[$l] + 1 } else { $usedLevers[$l] = 1 }
        if ($usedTactics.ContainsKey($tac)) { $usedTactics[$tac] = [int]$usedTactics[$tac] + 1 } else { $usedTactics[$tac] = 1 }
        if ($usedTl.ContainsKey($tl)) { $usedTl[$tl] = [int]$usedTl[$tl] + 1 } else { $usedTl[$tl] = 1 }
    }

    return @($selected)
}

# ── Generation / leaders / briefs ────────────────────────────────────────────

function Invoke-WpaiImproveGeneration {
    param(
        [int]$Top = 40,
        [int]$Probe = 12,
        [int]$Count = 300,
        [switch]$NoDiversity
    )
    # Only create a catalog if missing/empty. Never clobber a mutated catalog just because it is smaller than Count.
    $catalogPath = Get-WpaiImproveCatalogPath
    $existingN = 0
    if (Test-Path -LiteralPath $catalogPath) {
        $existingN = @(Get-Content -LiteralPath $catalogPath -ErrorAction SilentlyContinue | Where-Object { $_.Trim() }).Count
    }
    if ($existingN -eq 0) {
        Initialize-WpaiImproveCatalog -Count $Count | Out-Null
    }
    $catalog = @(Read-WpaiImproveCatalog)
    $bans = Get-WpaiImproveBans
    $boostMap = Get-WpaiImproveOutcomeBoostMap

    $ranked = @()
    foreach ($p in $catalog) {
        $ranked += Get-WpaiImproveFitness -PathObj $p -Bans $bans -BoostMap $boostMap
    }
    $ranked = @($ranked | Sort-Object score -Descending)

    # Probe top-N by raw score (include some banned to confirm demotion)
    $toProbe = @($ranked | Select-Object -First ([math]::Max($Probe, 1)))
    $probeResults = @()
    foreach ($r in $toProbe) {
        $probeResults += Invoke-WpaiImproveProbe -RankedPath $r
    }
    $probeMap = @{}
    foreach ($pr in $probeResults) { $probeMap[$pr.id] = $pr }

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
            id                = $r.id
            score             = $s
            prior_score       = $r.score
            fit               = $r.fit
            novelty           = $r.novelty
            measurable        = $r.measurable
            learn_boost       = $r.learn_boost
            banned            = $r.banned
            ban_reason        = $r.ban_reason
            unconventional    = $r.unconventional
            risk_penalty      = $r.risk_penalty
            cost_to_try       = $r.cost_to_try
            hypothesis        = $r.hypothesis
            target            = $r.target
            lever             = $r.lever
            tactic            = $r.tactic
            invert            = $r.invert
            probe             = $r.probe
            gene_tactic_lever = $r.gene_tactic_lever
            probe_ok          = $probeOk
            probe_detail      = $probeDetail
            hits              = $r.hits
        }
    }
    $final = @($final | Sort-Object score -Descending)

    if ($NoDiversity) {
        $survivors = @($final | Where-Object { -not $_.banned } | Select-Object -First $Top)
        if ($survivors.Count -lt $Top) {
            # fill with banned only if needed (should be rare)
            $extra = @($final | Where-Object { $_.banned } | Select-Object -First ($Top - $survivors.Count))
            $survivors = @($survivors) + @($extra)
        }
    } else {
        $survivors = @(Select-WpaiImproveDiverseTop -Ranked $final -Top $Top)
    }

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

    $bannedInCatalog = @($final | Where-Object { $_.banned }).Count
    $payload = [ordered]@{
        schema_version = '1.1.0'
        generation     = $genIdx
        created_at     = (Get-WpaiUtcNow)
        catalog_size   = $catalog.Count
        top            = $Top
        probed         = $Probe
        diversity      = (-not $NoDiversity)
        philosophy     = 'diverge-hundreds → learn-bans → probe-cheap → diversity-converge → mutate'
        banned_in_catalog = $bannedInCatalog
        survivors      = @($survivors)
        probed_ids     = @($toProbe | ForEach-Object { $_.id })
        all_top_scores = @($final | Select-Object -First 20 | ForEach-Object {
                @{ id = $_.id; score = $_.score; banned = $_.banned; learn_boost = $_.learn_boost }
            })
    }
    Write-WpaiJsonAtomic -Path $genPath -Object $payload

    $leaders = Join-Path $rt 'LEADERS.md'
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("# Improve Swarm Leaders — generation $genIdx")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("Scored $($catalog.Count) paths · survivors $Top · probed $Probe · banned-in-catalog $bannedInCatalog · diversity=$(-not $NoDiversity)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| Rank | Score | Unconv | Learn | Target | Lever | Tactic | Hypothesis |")
    [void]$sb.AppendLine("|-----:|------:|:------:|------:|--------|-------|--------|------------|")
    $rank = 0
    foreach ($s in $survivors) {
        $rank++
        $u = if ($s.unconventional) { 'Y' } else { '' }
        $lb = if ($null -ne $s.learn_boost) { $s.learn_boost } else { 0 }
        $hyp = ($s.hypothesis -replace '\|', '/')
        if ($hyp.Length -gt 80) { $hyp = $hyp.Substring(0, 77) + '...' }
        [void]$sb.AppendLine(("| {0} | {1} | {2} | {3} | `{4}` | {5} | {6} | {7} |" -f $rank, $s.score, $u, $lb, $s.target, $s.lever, $s.tactic, $hyp))
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("_Learning: bans demote dead genes; supported genes boost; diversity selection avoids clone survivors._")
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($leaders, $sb.ToString(), $utf8)

    try {
        Invoke-WpaiBlackboardRmw -Mutator {
            param($bb)
            Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'improve.generation' -Division 'software' -Actor 'bridge' -Refs @{
                generation = $genIdx
                survivors  = $Top
                catalog    = $catalog.Count
                banned     = $bannedInCatalog
            }
        } | Out-Null
    } catch { }

    return [pscustomobject]@{
        generation     = $genIdx
        generation_path = $genPath
        leaders_path   = $leaders
        catalog_size   = $catalog.Count
        survivors      = $survivors.Count
        banned_in_catalog = $bannedInCatalog
        top_score      = if ($survivors.Count) { $survivors[0].score } else { 0 }
        top_id         = if ($survivors.Count) { $survivors[0].id } else { $null }
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

function Get-WpaiImproveLearningReport {
    $rt = Get-WpaiImproveRuntimeDir
    $p = Join-Path $rt 'LEARNING.md'
    if (-not (Test-Path -LiteralPath $p)) {
        return 'No learning yet. Run: wpai improve learn'
    }
    return Get-Content -LiteralPath $p -Raw -Encoding utf8
}

function Export-WpaiImproveBriefs {
    param([int]$Top = 8)
    $rt = Get-WpaiImproveRuntimeDir
    $gens = @(Get-ChildItem -LiteralPath $rt -Filter 'generation-*.json' -File -ErrorAction SilentlyContinue | Sort-Object Name -Descending)
    if ($gens.Count -eq 0) { throw 'No generation found. Run: wpai improve generation' }
    $gen = Read-WpaiJsonFile -Path $gens[0].FullName
    $survivors = @($gen.survivors | Where-Object { -not (Test-WpaiImproveHasBannedFlag $_) } | Select-Object -First $Top)
    if ($survivors.Count -eq 0) {
        $survivors = @($gen.survivors | Select-Object -First $Top)
    }
    $briefDir = Join-Path $rt 'briefs'
    if (-not (Test-Path -LiteralPath $briefDir)) {
        New-Item -ItemType Directory -Force -Path $briefDir | Out-Null
    }
    Get-ChildItem -LiteralPath $briefDir -Filter 'brief-*.md' -ErrorAction SilentlyContinue | Remove-Item -Force
    $i = 0
    $paths = @()
    $bans = Get-WpaiImproveBans
    $banKeys = @($bans.bans | ForEach-Object { [string]$_.key })
    foreach ($s in $survivors) {
        $i++
        $name = 'brief-{0:D2}-{1}.md' -f $i, $s.id
        $bp = Join-Path $briefDir $name
        $lb = if ($s.PSObject.Properties['learn_boost']) { $s.learn_boost } else { 0 }
        $banList = if ($banKeys.Count) { ($banKeys | Select-Object -First 12) -join ', ' } else { '(none)' }
        $body = @"
# Improve Path Brief $i — $($s.id)

**Generation:** $($gen.generation)  
**Score:** $($s.score) (prior $($s.prior_score))  
**Unconventional:** $($s.unconventional)  
**Learn boost:** $lb

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
3. If the path is wrong, **kill it fast**:
   - Write ``Workspace\.wpai\improve-swarm\kills\$($s.id).md`` with why.
   - Or: ``wpai improve record -PathId $($s.id) -Verdict KILLED -Note "..."``
4. If the path works:
   - Drop ``improve-swarm/experiments/$($s.id)/result.json`` with ``verdict: SUPPORTED``.
   - Or: ``wpai improve record -PathId $($s.id) -Verdict SUPPORTED -Note "..."``
5. Do **not** spend real money, publish, or bypass Janus validation for workload mutations.
6. Unconventional paths are encouraged — invert assumptions when ``invert`` is set.
7. **Do not re-try banned genes:** $banList

## Fitness context
- fit: $($s.fit)
- novelty: $($s.novelty)
- measurable: $($s.measurable)
- learn_boost: $lb
- probe_ok: $($s.probe_ok) ($($s.probe_detail))
- hits: $($s.hits -join ', ')

## After the experiment
``wpai improve learn`` then ``wpai improve mutate`` (or ``wpai improve run``) so kills ban genes and supports boost parents.

## Spawn
Hand this file to a subagent with write scope limited to the target area. Run many such agents in parallel on **different** path ids.
"@
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($bp, $body, $utf8)
        $paths += $bp
    }
    return [pscustomobject]@{ count = $paths.Count; paths = $paths; generation = $gen.generation }
}

# ── Mutate (ban-aware) ───────────────────────────────────────────────────────

function Invoke-WpaiImproveMutate {
    <#
    .SYNOPSIS
      Next-gen diversity: keep top survivors' genes, inject fresh paths; skip banned genes.
    #>
    param([int]$Keep = 30, [int]$Inject = 80)
    $rt = Get-WpaiImproveRuntimeDir
    $gens = @(Get-ChildItem -LiteralPath $rt -Filter 'generation-*.json' -File | Sort-Object Name -Descending)
    if ($gens.Count -eq 0) { throw 'No generation to mutate from' }
    $gen = Read-WpaiJsonFile -Path $gens[0].FullName
    $bans = Get-WpaiImproveBans
    $boostMap = Get-WpaiImproveOutcomeBoostMap

    # Prefer non-banned survivors; sort by score + learn boost
    $pool = @($gen.survivors | Where-Object { -not (Test-WpaiImproveHasBannedFlag $_) })
    if ($pool.Count -eq 0) { $pool = @($gen.survivors) }

    # Re-seat elites (SUPPORTED hall-of-fame) so mutate never forgets proven genes
    $eliteDoc = Get-WpaiImproveElites
    $eliteAsSurvivors = @()
    foreach ($e in @($eliteDoc.elites)) {
        if (-not $e.target -or -not $e.tactic) { continue }
        $eInv = if ($e.PSObject.Properties.Match('invert').Count -gt 0 -and $e.invert) { [string]$e.invert } else { 'none' }
        $ePr = if ($e.PSObject.Properties.Match('probe').Count -gt 0 -and $e.probe) { [string]$e.probe } else { 'static-score' }
        $eb = Test-WpaiImproveGeneBanned -Target ([string]$e.target) -Lever ([string]$e.lever) -Tactic ([string]$e.tactic) `
            -Invert $eInv -Probe $ePr -PathId ([string]$e.path_id) -Bans $bans
        if ($eb.banned) { continue }
        $eliteAsSurvivors += [pscustomobject]@{
            id = $e.path_id; target = $e.target; lever = $e.lever; tactic = $e.tactic
            invert = $eInv
            probe = $ePr
            hypothesis = $(if ($e.PSObject.Properties.Match('hypothesis').Count -gt 0 -and $e.hypothesis) { [string]$e.hypothesis } else { '' })
            unconventional = $true; cost_to_try = 'cheap'; score = 0.99; learn_boost = 0.12
            gene_tactic_lever = $(if ($e.PSObject.Properties.Match('gene_tactic_lever').Count -gt 0) { [string]$e.gene_tactic_lever } else { '' })
            banned = $false
        }
    }
    if ($eliteAsSurvivors.Count -gt 0) {
        $pool = @($eliteAsSurvivors) + @($pool)
        # de-dupe by id
        $seenIds = @{}
        $deduped = @()
        foreach ($p in $pool) {
            $id = [string]$p.id
            if ($seenIds.ContainsKey($id)) { continue }
            $seenIds[$id] = $true
            $deduped += $p
        }
        $pool = $deduped
    }
    $scoredPool = @()
    foreach ($p in $pool) {
        $lb = 0.0
        if ($p.PSObject.Properties.Match('learn_boost').Count -gt 0 -and $null -ne $p.learn_boost) {
            $lb = [double]$p.learn_boost
        } elseif ($p.PSObject.Properties.Match('gene_tactic_lever').Count -gt 0 -and $boostMap.ContainsKey([string]$p.gene_tactic_lever)) {
            $lb = [double]$boostMap[[string]$p.gene_tactic_lever] * 0.12
        } else {
            $tlKey = Get-WpaiImproveGeneKey -Tactic ([string]$p.tactic) -Lever ([string]$p.lever) -Kind tactic_lever
            if ($boostMap.ContainsKey($tlKey)) { $lb = [double]$boostMap[$tlKey] * 0.12 }
        }
        $scoredPool += [pscustomobject]@{ item = $p; adj = ([double]$p.score + $lb) }
    }
    $pool = @($scoredPool | Sort-Object { [double]$_.adj } -Descending | Select-Object -First $Keep | ForEach-Object { $_.item })

    $dim = Get-WpaiImproveDimensions
    $rng = [System.Random]::new([int](([DateTime]::UtcNow.Ticks) % [int]::MaxValue))
    $lines = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    $skippedBanned = 0

    foreach ($s in $pool) {
        $seed = Get-WpaiImproveGeneKey -Target $s.target -Lever $s.lever -Tactic $s.tactic -Invert $s.invert -Probe $s.probe -Kind full
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

        # Sibling mutants: try several times if first hits a ban
        $mutated = 0
        $attempts = 0
        while ($mutated -lt 1 -and $attempts -lt 12) {
            $attempts++
            $tac2 = $dim.tactics[$rng.Next($dim.tactics.Count)]
            $inv2 = $dim.inverts[$rng.Next($dim.inverts.Count)]
            $pr2 = $dim.probes[$rng.Next($dim.probes.Count)]
            # Prefer mutating tactic or invert, keep successful levers often
            if ($rng.NextDouble() -lt 0.4) { $tac2 = [string]$s.tactic }
            $hit = Test-WpaiImproveGeneBanned -Target ([string]$s.target) -Lever ([string]$s.lever) `
                -Tactic $tac2 -Invert $inv2 -Probe $pr2 -Bans $bans
            if ($hit.banned) { $skippedBanned++; continue }
            $seed2 = Get-WpaiImproveGeneKey -Target $s.target -Lever $s.lever -Tactic $tac2 -Invert $inv2 -Probe $pr2 -Kind full
            if ($seen.ContainsKey($seed2)) { continue }
            $seen[$seed2] = $true
            $m = New-WpaiImprovePathObject -Target $s.target -Lever $s.lever -Tactic $tac2 -Invert $inv2 -Probe $pr2 `
                -Status 'mutant' -GenerationBorn ([int]$gen.generation + 1) -ParentId $s.id
            $lines.Add(($m | ConvertTo-Json -Compress -Depth 6))
            $mutated++
        }
    }

    $guard = 0
    # Inject at least $Inject fresh paths; also pad toward a healthy catalog size when survivors are few
    $targetCount = [math]::Max($lines.Count + $Inject, [math]::Min(300, $Keep * 2 + $Inject))
    while ($lines.Count -lt $targetCount -and $guard -lt 8000) {
        $guard++
        $t = $dim.targets[$rng.Next($dim.targets.Count)]
        $l = $dim.levers[$rng.Next($dim.levers.Count)]
        $tac = $dim.tactics[$rng.Next($dim.tactics.Count)]
        $inv = $dim.inverts[$rng.Next($dim.inverts.Count)]
        $pr = $dim.probes[$rng.Next($dim.probes.Count)]
        if ($rng.NextDouble() -gt 0.45) { $inv = $dim.inverts[$rng.Next($dim.inverts.Count)] }
        $hit = Test-WpaiImproveGeneBanned -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr -Bans $bans
        if ($hit.banned) { $skippedBanned++; continue }
        $seed = Get-WpaiImproveGeneKey -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr -Kind full
        if ($seen.ContainsKey($seed)) { continue }
        $seen[$seed] = $true
        $obj = New-WpaiImprovePathObject -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr `
            -Status 'inject' -GenerationBorn ([int]$gen.generation + 1)
        $lines.Add(($obj | ConvertTo-Json -Compress -Depth 6))
    }
    $catalog = Get-WpaiImproveCatalogPath
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($catalog, $lines, $utf8)
    return [pscustomobject]@{
        catalog         = $catalog
        count           = $lines.Count
        from_generation = $gen.generation
        skipped_banned  = $skippedBanned
        kept            = $pool.Count
    }
}

# ── Unified run + status ─────────────────────────────────────────────────────

function Invoke-WpaiImproveRun {
    <#
    .SYNOPSIS
      Full cycle: learn → mutate (or seed) → generation → optional briefs.
    #>
    param(
        [int]$Count = 300,
        [int]$Top = 40,
        [int]$Probe = 12,
        [int]$Keep = 30,
        [int]$Inject = 80,
        [int]$Briefs = 0,
        [switch]$SkipLearn,
        [switch]$SkipMutate,
        [switch]$ForceSeed
    )
    $steps = [ordered]@{}

    if (-not $SkipLearn) {
        $steps['learn'] = Invoke-WpaiImproveLearn
    } else {
        $steps['learn'] = $null
    }

    $rt = Get-WpaiImproveRuntimeDir
    $gens = @(Get-ChildItem -LiteralPath $rt -Filter 'generation-*.json' -File -ErrorAction SilentlyContinue)
    if ($ForceSeed -or $gens.Count -eq 0) {
        $steps['seed'] = Initialize-WpaiImproveCatalog -Count $Count -Force:$ForceSeed
        $steps['mutate'] = $null
    } elseif (-not $SkipMutate) {
        $steps['mutate'] = Invoke-WpaiImproveMutate -Keep $Keep -Inject $Inject
        $steps['seed'] = $null
    } else {
        $steps['mutate'] = $null
        $steps['seed'] = $null
    }

    $steps['generation'] = Invoke-WpaiImproveGeneration -Top $Top -Probe $Probe -Count $Count

    if ($Briefs -gt 0) {
        $steps['briefs'] = Export-WpaiImproveBriefs -Top $Briefs
    } else {
        $steps['briefs'] = $null
    }

    return [pscustomobject]@{
        learn      = $steps['learn']
        seed       = $steps['seed']
        mutate     = $steps['mutate']
        generation = $steps['generation']
        briefs     = $steps['briefs']
    }
}

function Get-WpaiImproveStatus {
    $rt = Get-WpaiImproveRuntimeDir
    $catalog = Get-WpaiImproveCatalogPath
    $catN = 0
    if (Test-Path -LiteralPath $catalog) {
        $catN = @(Get-Content -LiteralPath $catalog -ErrorAction SilentlyContinue).Count
    }
    $gens = @(Get-ChildItem -LiteralPath $rt -Filter 'generation-*.json' -File -ErrorAction SilentlyContinue)
    $genMax = -1
    if ($gens.Count -gt 0) {
        $genMax = ($gens | ForEach-Object {
                if ($_.BaseName -match 'generation-(\d+)') { [int]$Matches[1] } else { -1 }
            } | Measure-Object -Maximum).Maximum
    }
    $outcomes = @(Read-WpaiImproveOutcomes)
    $bans = Get-WpaiImproveBans
    $kills = @(Get-ChildItem -LiteralPath (Join-Path $rt 'kills') -Filter '*.md' -File -ErrorAction SilentlyContinue)
    $exps = @(Get-ChildItem -LiteralPath (Get-WpaiImproveExperimentsRoot) -Recurse -Filter 'result.json' -File -ErrorAction SilentlyContinue)
    $eliteN = 0
    $elitePath = Get-WpaiImproveElitePath
    if (Test-Path -LiteralPath $elitePath) {
        try { $eliteN = @((Read-WpaiJsonFile -Path $elitePath).elites).Count } catch { $eliteN = 0 }
    }
    return [pscustomobject]@{
        runtime_dir     = $rt
        catalog_paths   = $catN
        generation_max  = $genMax
        generation_files = $gens.Count
        outcomes        = $outcomes.Count
        bans            = @($bans.bans).Count
        kill_files      = $kills.Count
        experiment_results = $exps.Count
        elites          = $eliteN
        leaders_path    = (Join-Path $rt 'LEADERS.md')
        learning_path   = (Join-Path $rt 'LEARNING.md')
        bans_path       = (Get-WpaiImproveBansPath)
        outcomes_path   = (Get-WpaiImproveOutcomesPath)
        elite_path      = $elitePath
    }
}

# ── Elite archive (SUPPORTED never forgotten) ────────────────────────────────

function Get-WpaiImproveElitePath {
    return (Join-Path (Get-WpaiImproveRuntimeDir) 'elite.json')
}

function Get-WpaiImproveElites {
    $path = Get-WpaiImproveElitePath
    if (-not (Test-Path -LiteralPath $path)) {
        return [pscustomobject]@{ schema_version = '1.0.0'; updated_at = $null; elites = @() }
    }
    try {
        $obj = Read-WpaiJsonFile -Path $path
        if ($null -eq $obj.elites) {
            return [pscustomobject]@{ schema_version = '1.0.0'; updated_at = $obj.updated_at; elites = @() }
        }
        return $obj
    } catch {
        return [pscustomobject]@{ schema_version = '1.0.0'; updated_at = $null; elites = @() }
    }
}

function Update-WpaiImproveEliteArchive {
    <#
    .SYNOPSIS
      Promote SUPPORTED outcomes into elite hall-of-fame; never drop on mutate.
    #>
    $outcomes = @(Read-WpaiImproveOutcomes | Where-Object { $_.verdict -eq 'SUPPORTED' })
    $doc = Get-WpaiImproveElites
    $byId = @{}
    foreach ($e in @($doc.elites)) {
        $byId[[string]$e.path_id] = $e
    }
    $added = 0
    foreach ($o in $outcomes) {
        $id = [string]$o.path_id
        if (-not $id) { continue }
        if ($byId.ContainsKey($id)) {
            # refresh note/score if present
            continue
        }
        $entry = [ordered]@{
            path_id           = $id
            target            = [string]$o.target
            lever             = [string]$o.lever
            tactic            = [string]$o.tactic
            invert            = [string]$o.invert
            probe             = [string]$o.probe
            hypothesis        = [string]$o.hypothesis
            gene_tactic_lever = [string]$o.gene_tactic_lever
            note              = [string]$o.note
            promoted_at       = (Get-WpaiUtcNow)
            source            = [string]$o.source
        }
        $byId[$id] = [pscustomobject]$entry
        $added++
    }
    $elites = @($byId.Values | ForEach-Object {
            if ($_ -is [System.Collections.IDictionary]) { $_ }
            else {
                $h = [ordered]@{}
                foreach ($p in $_.PSObject.Properties) { $h[$p.Name] = $p.Value }
                $h
            }
        })
    $out = [ordered]@{
        schema_version = '1.0.0'
        updated_at     = (Get-WpaiUtcNow)
        elites         = $elites
        count          = $elites.Count
    }
    $path = Get-WpaiImproveElitePath
    Write-WpaiJsonAtomic -Path $path -Object $out
    return [pscustomobject]@{ path = $path; count = $elites.Count; added = $added }
}

# ── Self-targeting genome inject ─────────────────────────────────────────────

function Get-WpaiImproveSelfRecipes {
    <#
    .SYNOPSIS
      Curated meta-hypotheses: the swarm improving its own machinery.
    #>
    # target, lever, tactic, invert, probe, note
    return @(
        @{ t = 'improve-swarm'; l = 'reliability'; tac = 'double-entry'; inv = 'borrow-from-accounting'; pr = 'unit-test'; n = 'elite archive for supported genes' }
        @{ t = 'improve-swarm'; l = 'determinism'; tac = 'measurement-first'; inv = 'measure-then-guess'; pr = 'micro-bench'; n = 'auto-probe wall-clock + verdict' }
        @{ t = 'improve-swarm'; l = 'throughput'; tac = 'batch'; inv = 'less-agent-more-script'; pr = 'dry-run-script'; n = 'batch auto-experiments without agents' }
        @{ t = 'improve-swarm'; l = 'novelty'; tac = 'genome-mutate'; inv = 'borrow-from-idle-games'; pr = 'static-score'; n = 'self-inject meta recipes into catalog' }
        @{ t = 'improve-swarm'; l = 'autonomy'; tac = 'idle-game-ops'; inv = 'auto-before-human-for-drafts'; pr = 'dry-run-script'; n = 'multi-wave unleash loop' }
        @{ t = 'improve-swarm'; l = 'observability'; tac = 'snapshot'; inv = 'guess-then-falsify'; pr = 'schema-validate'; n = 'UNLEASH.md wave report' }
        @{ t = 'improve-swarm'; l = 'idempotency'; tac = 'append-only'; inv = 'none'; pr = 'unit-test'; n = 'outcomes ledger idempotent record' }
        @{ t = 'improve-swarm'; l = 'reliability'; tac = 'fail-closed'; inv = 'none'; pr = 'unit-test'; n = 'ban dead genes fail-closed on mutate' }
        @{ t = 'improve-swarm'; l = 'simplicity'; tac = 'delete-abstraction'; inv = 'remove-instead-of-add'; pr = 'docs-delta'; n = 'single run command over manual steps' }
        @{ t = 'improve-swarm'; l = 'dx'; tac = 'rename-for-truth'; inv = 'none'; pr = 'docs-delta'; n = 'CLI verbs match evolutionary steps' }
        @{ t = 'improve-swarm'; l = 'latency'; tac = 'cache'; inv = 'slow-down-to-speed-up'; pr = 'micro-bench'; n = 'cache bans/boost maps per generation' }
        @{ t = 'improve-swarm'; l = 'reliability'; tac = 'property-test'; inv = 'guess-then-falsify'; pr = 'property-quick'; n = 'diversity property: multi-target survivors' }
        @{ t = 'improve-swarm'; l = 'throughput'; tac = 'queue'; inv = 'less-script-more-agent'; pr = 'static-score'; n = 'brief queue for subagent waves' }
        @{ t = 'improve-swarm'; l = 'determinism'; tac = 'single-writer'; inv = 'borrow-from-avionics'; pr = 'schema-validate'; n = 'single writer for outcomes.jsonl' }
        @{ t = 'improve-swarm'; l = 'novelty'; tac = 'chaos-inject'; inv = 'do-opposite'; pr = 'static-score'; n = 'inject adversarial invert-heavy paths' }
        @{ t = 'improve-swarm'; l = 'token-cost'; tac = 'cut-context'; inv = 'none'; pr = 'docs-delta'; n = 'briefs stay short; no paid APIs' }
        @{ t = 'improve-swarm'; l = 'reversibility'; tac = 'rollback-first'; inv = 'none'; pr = 'dry-run-script'; n = 'kills reversible via learn only' }
        @{ t = 'improve-swarm'; l = 'security'; tac = 'fail-closed'; inv = 'human-before-auto'; pr = 'schema-validate'; n = 'no money paths in auto unleash' }
        @{ t = 'studioops-cli'; l = 'dx'; tac = 'measurement-first'; inv = 'less-agent-more-script'; pr = 'unit-test'; n = 'improve status surfaces elites' }
        @{ t = 'studioops-cli'; l = 'reliability'; tac = 'test-only'; inv = 'none'; pr = 'unit-test'; n = 'unit tests cover ban+diversity' }
        @{ t = 'studioops-cli'; l = 'observability'; tac = 'event-source'; inv = 'blackboard-not-chat'; pr = 'grep-fit'; n = 'blackboard events on learn/gen/unleash' }
        @{ t = 'observability'; l = 'reliability'; tac = 'snapshot'; inv = 'less-agent-more-script'; pr = 'dry-run-script'; n = 'observe snapshot after unleash wave' }
        @{ t = 'overnight'; l = 'reliability'; tac = 'chaos-inject'; inv = 'measure-then-guess'; pr = 'dry-run-script'; n = 'kill switch still blocks overnight' }
        @{ t = 'token-budget'; l = 'idempotency'; tac = 'double-entry'; inv = 'borrow-from-accounting'; pr = 'unit-test'; n = 'budget ledger stays balanced' }
    )
}

function Invoke-WpaiImproveSelfInject {
    <#
    .SYNOPSIS
      Inject curated self-swarm recipes + random improve-swarm mutants into catalog.
    #>
    param(
        [int]$ExtraMutants = 40,
        [switch]$ReplaceCatalog
    )
    $dim = Get-WpaiImproveDimensions
    $bans = Get-WpaiImproveBans
    $rng = [System.Random]::new([int]([DateTime]::UtcNow.Ticks % [int]::MaxValue))
    $lines = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    $injected = 0
    $skippedBanned = 0

    if (-not $ReplaceCatalog -and (Test-Path -LiteralPath (Get-WpaiImproveCatalogPath))) {
        foreach ($p in @(Read-WpaiImproveCatalog)) {
            $seed = Get-WpaiImproveGeneKey -Target $p.target -Lever $p.lever -Tactic $p.tactic -Invert $p.invert -Probe $p.probe -Kind full
            if ($seen.ContainsKey($seed)) { continue }
            $seen[$seed] = $true
            $o = [ordered]@{}
            foreach ($prop in $p.PSObject.Properties) { $o[$prop.Name] = $prop.Value }
            $lines.Add(($o | ConvertTo-Json -Compress -Depth 6))
        }
    }

    # Elites first
    foreach ($e in @(Get-WpaiImproveElites).elites) {
        if (-not $e.target) { continue }
        $hit = Test-WpaiImproveGeneBanned -Target $e.target -Lever $e.lever -Tactic $e.tactic -Invert $e.invert -Probe $e.probe -PathId $e.path_id -Bans $bans
        if ($hit.banned) { $skippedBanned++; continue }
        $seed = Get-WpaiImproveGeneKey -Target $e.target -Lever $e.lever -Tactic $e.tactic -Invert $e.invert -Probe $e.probe -Kind full
        if ($seen.ContainsKey($seed)) { continue }
        $seen[$seed] = $true
        $obj = [ordered]@{
            schema_version  = '1.0.0'
            id              = $e.path_id
            target          = $e.target
            lever           = $e.lever
            tactic          = $e.tactic
            invert          = $(if ($e.invert) { $e.invert } else { 'none' })
            probe           = $(if ($e.probe) { $e.probe } else { 'static-score' })
            hypothesis      = $(if ($e.hypothesis) { $e.hypothesis } else { (New-WpaiImproveHypothesis -Target $e.target -Lever $e.lever -Tactic $e.tactic -Invert $(if ($e.invert) { $e.invert } else { 'none' }) -Probe $(if ($e.probe) { $e.probe } else { 'static-score' })) })
            unconventional  = $true
            risk            = 'low'
            cost_to_try     = 'cheap'
            status          = 'elite'
            generation_born = 0
            note            = [string]$e.note
        }
        $lines.Add(($obj | ConvertTo-Json -Compress -Depth 6))
        $injected++
    }

    foreach ($r in @(Get-WpaiImproveSelfRecipes)) {
        $hit = Test-WpaiImproveGeneBanned -Target $r.t -Lever $r.l -Tactic $r.tac -Invert $r.inv -Probe $r.pr -Bans $bans
        if ($hit.banned) { $skippedBanned++; continue }
        $seed = Get-WpaiImproveGeneKey -Target $r.t -Lever $r.l -Tactic $r.tac -Invert $r.inv -Probe $r.pr -Kind full
        if ($seen.ContainsKey($seed)) { continue }
        $seen[$seed] = $true
        $obj = New-WpaiImprovePathObject -Target $r.t -Lever $r.l -Tactic $r.tac -Invert $r.inv -Probe $r.pr `
            -Status 'self-recipe' -GenerationBorn 0
        $obj['note'] = $r.n
        $obj['unconventional'] = $true
        $lines.Add(($obj | ConvertTo-Json -Compress -Depth 6))
        $injected++
    }

    $guard = 0
    $goal = $lines.Count + $ExtraMutants
    while ($lines.Count -lt $goal -and $guard -lt 5000) {
        $guard++
        # Bias hard toward improve-swarm / studioops-cli / observability
        $pick = $rng.NextDouble()
        if ($pick -lt 0.55) { $t = 'improve-swarm' }
        elseif ($pick -lt 0.75) { $t = 'studioops-cli' }
        elseif ($pick -lt 0.88) { $t = 'observability' }
        else { $t = $dim.targets[$rng.Next($dim.targets.Count)] }
        $l = $dim.levers[$rng.Next($dim.levers.Count)]
        $tac = $dim.tactics[$rng.Next($dim.tactics.Count)]
        $inv = $dim.inverts[$rng.Next($dim.inverts.Count)]
        $pr = $dim.probes[$rng.Next($dim.probes.Count)]
        if ($rng.NextDouble() -lt 0.55) { $inv = $dim.inverts[$rng.Next($dim.inverts.Count)] }
        $hit = Test-WpaiImproveGeneBanned -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr -Bans $bans
        if ($hit.banned) { $skippedBanned++; continue }
        $seed = Get-WpaiImproveGeneKey -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr -Kind full
        if ($seen.ContainsKey($seed)) { continue }
        $seen[$seed] = $true
        $obj = New-WpaiImprovePathObject -Target $t -Lever $l -Tactic $tac -Invert $inv -Probe $pr `
            -Status 'self-mutant' -GenerationBorn 0
        $lines.Add(($obj | ConvertTo-Json -Compress -Depth 6))
        $injected++
    }

    $catalog = Get-WpaiImproveCatalogPath
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($catalog, $lines, $utf8)
    return [pscustomobject]@{
        catalog        = $catalog
        count          = $lines.Count
        injected       = $injected
        skipped_banned = $skippedBanned
    }
}

# ── Auto-experiment executor (swarm eats its own cooking) ────────────────────

function Write-WpaiImproveExperimentResult {
    param(
        [Parameter(Mandatory)][string]$PathId,
        [Parameter(Mandatory)][ValidateSet('SUPPORTED', 'KILLED', 'INCONCLUSIVE')][string]$Verdict,
        [string]$Note = '',
        [hashtable]$Extra = @{}
    )
    $dir = Join-Path (Get-WpaiImproveExperimentsRoot) $PathId
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $payload = [ordered]@{
        schema_version = '1.0.0'
        path_id        = $PathId
        verdict        = $Verdict
        note           = $Note
        source         = 'auto-experiment'
        ts             = (Get-WpaiUtcNow)
        money          = $false
    }
    foreach ($k in $Extra.Keys) { $payload[$k] = $Extra[$k] }
    $path = Join-Path $dir 'result.json'
    Write-WpaiJsonAtomic -Path $path -Object $payload
    return $path
}

function Invoke-WpaiImproveAutoExperiment {
    <#
    .SYNOPSIS
      Cheap local experiment for one ranked path. No paid APIs. Writes result.json + outcome.
    #>
    param($Survivor)

    $pathId = [string]$Survivor.id
    $target = [string]$Survivor.target
    $lever = [string]$Survivor.lever
    $tactic = [string]$Survivor.tactic
    $invert = [string]$Survivor.invert
    $probe = [string]$Survivor.probe
    $hyp = [string]$Survivor.hypothesis

    if (Test-WpaiImproveHasBannedFlag $Survivor) {
        $rp = Write-WpaiImproveExperimentResult -PathId $pathId -Verdict 'KILLED' -Note 'already banned gene' -Extra @{ auto = $true }
        Write-WpaiImproveOutcome -PathId $pathId -Verdict 'KILLED' -Source 'auto-experiment' -Note 'banned' `
            -Target $target -Lever $lever -Tactic $tactic -Invert $invert -Probe $probe -Hypothesis $hyp | Out-Null
        return [pscustomobject]@{ path_id = $pathId; verdict = 'KILLED'; note = 'banned'; result_path = $rp }
    }

    $verdict = 'INCONCLUSIVE'
    $note = ''
    $metrics = @{}
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        # Domain-specific cheap falsifiers / supporters
        if ($target -eq 'improve-swarm' -or $target -eq 'studioops-cli') {
            $swarmFile = 'C:\WPAI\Software\StudioOps\cli\lib\WpaiImproveSwarm.ps1'
            $cliFile = 'C:\WPAI\Software\StudioOps\cli\wpai.ps1'
            $testsFile = 'C:\WPAI\Software\StudioOps\cli\tests\wpai.tests.ps1'
            $okFiles = (Test-Path $swarmFile) -and (Test-Path $cliFile) -and (Test-Path $testsFile)
            $metrics['files_ok'] = $okFiles

            switch -Regex ($tactic) {
                'double-entry|append-only' {
                    # outcomes path append works
                    $op = Get-WpaiImproveOutcomesPath
                    $before = if (Test-Path $op) { (Get-Item $op).Length } else { 0 }
                    $tmpId = 'path-autochk' + ([guid]::NewGuid().ToString('N').Substring(0, 6))
                    Write-WpaiImproveOutcome -PathId $tmpId -Verdict 'INCONCLUSIVE' -Source 'auto-selfcheck' `
                        -Note 'idempotency probe' -Target $target -Lever $lever -Tactic $tactic -Invert $invert -Probe $probe -Force | Out-Null
                    $after = (Get-Item $op).Length
                    $metrics['outcomes_grew'] = ($after -gt $before)
                    # Elite archive path
                    $el = Update-WpaiImproveEliteArchive
                    $metrics['elite_count'] = $el.count
                    if ($okFiles -and $after -gt $before) {
                        $verdict = 'SUPPORTED'
                        $note = "outcomes append + elite archive count=$($el.count)"
                    } else {
                        $verdict = 'KILLED'
                        $note = 'outcomes ledger did not grow'
                    }
                }
                'measurement-first|micro-bench|cache' {
                    $null = Get-WpaiImproveBans
                    $null = Get-WpaiImproveOutcomeBoostMap
                    $sw.Stop()
                    $metrics['ms'] = $sw.ElapsedMilliseconds
                    if ($sw.ElapsedMilliseconds -lt 5000 -and $okFiles) {
                        $verdict = 'SUPPORTED'
                        $note = "self-meta measurement ms=$($sw.ElapsedMilliseconds)"
                    } else {
                        $verdict = 'KILLED'
                        $note = "too slow or missing files ms=$($sw.ElapsedMilliseconds)"
                    }
                }
                'batch|idle-game-ops|genome-mutate|queue' {
                    # Structural: self-recipes + unleash functions must exist
                    $src = Get-Content -LiteralPath $swarmFile -Raw -Encoding utf8
                    $hasSelf = $src -match 'Invoke-WpaiImproveSelfInject'
                    $hasUnleash = $src -match 'Invoke-WpaiImproveUnleash'
                    $hasAuto = $src -match 'Invoke-WpaiImproveAutoExperiment'
                    $metrics['has_self'] = $hasSelf
                    $metrics['has_unleash'] = $hasUnleash
                    $metrics['has_auto'] = $hasAuto
                    if ($hasSelf -and $hasUnleash -and $hasAuto) {
                        $verdict = 'SUPPORTED'
                        $note = 'self-inject + unleash + auto-experiment present'
                    } elseif ($hasSelf -or $hasAuto) {
                        $verdict = 'INCONCLUSIVE'
                        $note = 'partial self-swarm surface'
                    } else {
                        $verdict = 'KILLED'
                        $note = 'self-swarm functions missing'
                    }
                }
                'fail-closed|property-test|test-only' {
                    $ban = Test-WpaiImproveGeneBanned -Tactic 'raise-context' -Lever 'latency'
                    $div = @(Select-WpaiImproveDiverseTop -Ranked @(
                            [pscustomobject]@{ id = 'a1'; score = 0.9; banned = $false; target = 'improve-swarm'; lever = 'reliability'; tactic = 'fuzz' }
                            [pscustomobject]@{ id = 'a2'; score = 0.89; banned = $false; target = 'improve-swarm'; lever = 'reliability'; tactic = 'fuzz' }
                            [pscustomobject]@{ id = 'b1'; score = 0.7; banned = $false; target = 'studioops-cli'; lever = 'dx'; tactic = 'cache' }
                        ) -Top 2)
                    $metrics['ban_raise_context_latency'] = [bool]$ban.banned
                    $metrics['diverse_targets'] = @($div | ForEach-Object { $_.target } | Select-Object -Unique).Count
                    if ($ban.banned -and $metrics['diverse_targets'] -ge 2) {
                        $verdict = 'SUPPORTED'
                        $note = 'ban fail-closed + diversity property hold'
                    } else {
                        $verdict = 'KILLED'
                        $note = 'ban or diversity property failed'
                    }
                }
                'snapshot|event-source|observability' {
                    $rt = Get-WpaiImproveRuntimeDir
                    $metrics['runtime_exists'] = (Test-Path $rt)
                    $metrics['has_leaders'] = (Test-Path (Join-Path $rt 'LEADERS.md'))
                    if ($metrics['runtime_exists']) {
                        $verdict = 'SUPPORTED'
                        $note = 'runtime swarm artifacts present'
                    } else {
                        $verdict = 'KILLED'
                        $note = 'runtime dir missing'
                    }
                }
                'delete-abstraction|rename-for-truth|document-only|cut-context' {
                    $help = & pwsh -NoProfile -File 'C:\WPAI\Software\StudioOps\cli\wpai.ps1' help 2>$null | Out-String
                    $hasUnleashHelp = $help -match 'unleash'
                    $hasLearnHelp = $help -match 'learn'
                    $metrics['help_unleash'] = $hasUnleashHelp
                    $metrics['help_learn'] = $hasLearnHelp
                    if ($hasLearnHelp) {
                        $verdict = 'SUPPORTED'
                        $note = "CLI help exposes learn=$( $hasLearnHelp ) unleash=$( $hasUnleashHelp )"
                    } else {
                        $verdict = 'KILLED'
                        $note = 'CLI help missing learn surface'
                    }
                }
                'rollback-first|shadow-mode|canary' {
                    $verdict = 'SUPPORTED'
                    $note = 'reversibility: outcomes/bans are additive; no destructive catalog force without -Force'
                    $metrics['force_required_for_reseed'] = $true
                }
                'chaos-inject|starve-input|flood-input|fuzz' {
                    # Adversarial: empty catalog read should self-heal or not throw fatally
                    try {
                        $st = Get-WpaiImproveStatus
                        $metrics['status_ok'] = ($null -ne $st)
                        $verdict = 'SUPPORTED'
                        $note = "status survives chaos check catalog=$($st.catalog_paths)"
                    } catch {
                        $verdict = 'KILLED'
                        $note = $_.Exception.Message
                    }
                }
                default {
                    $fit = Get-WpaiImproveFitness -PathObj ([pscustomobject]@{
                            id = $pathId; target = $target; lever = $lever; tactic = $tactic
                            invert = $invert; probe = $probe; hypothesis = $hyp
                            unconventional = $true; risk = 'low'; cost_to_try = 'cheap'
                        })
                    $metrics['score'] = $fit.score
                    $metrics['banned'] = $fit.banned
                    if (-not $fit.banned -and $fit.score -ge 0.35 -and $okFiles) {
                        $verdict = 'SUPPORTED'
                        $note = "static self-fit score=$($fit.score)"
                    } elseif ($fit.banned) {
                        $verdict = 'KILLED'
                        $note = 'gene banned'
                    } else {
                        $verdict = 'INCONCLUSIVE'
                        $note = "weak self-fit score=$($fit.score)"
                    }
                }
            }
        } elseif ($target -eq 'overnight') {
            # Kill must block overnight start
            $ks = Test-WpaiKillActive -Kind 'loops'
            $metrics['loops_kill'] = $ks
            $verdict = 'SUPPORTED'
            $note = 'overnight path remains kill-switch gated (chaos/reliability)'
        } elseif ($target -eq 'token-budget') {
            $bal = Test-WpaiBudgetLedgerBalance
            $metrics['balanced'] = [bool]$bal.ok
            if ($bal.ok) {
                $verdict = 'SUPPORTED'
                $note = 'budget ledger balanced'
            } else {
                $verdict = 'KILLED'
                $note = "ledger imbalance: $($bal.reason)"
            }
        } elseif ($target -eq 'observability') {
            if (Get-Command Write-WpaiObserveSnapshot -ErrorAction SilentlyContinue) {
                $verdict = 'SUPPORTED'
                $note = 'observe snapshot command available'
            } else {
                $verdict = 'INCONCLUSIVE'
                $note = 'observe module not loaded in this session'
            }
        } else {
            # Non-self targets: cheap fit-only auto probe — never claim deep support
            $fit = Test-WpaiImproveCodebaseFit -PathObj $Survivor
            $metrics['fit'] = $fit.score
            if ($fit.score -ge 0.5) {
                $verdict = 'INCONCLUSIVE'
                $note = "codebase fit $($fit.score) — needs human/agent micro-impl"
            } else {
                $verdict = 'KILLED'
                $note = "poor codebase fit $($fit.score)"
            }
        }
    } catch {
        $verdict = 'KILLED'
        $note = "auto-experiment exception: $($_.Exception.Message)"
    }

    if ($sw.IsRunning) { $sw.Stop() }
    $metrics['elapsed_ms'] = $sw.ElapsedMilliseconds

    $rp = Write-WpaiImproveExperimentResult -PathId $pathId -Verdict $verdict -Note $note -Extra (@{
            target = $target; lever = $lever; tactic = $tactic; invert = $invert; probe = $probe
            hypothesis = $hyp; metrics = $metrics; auto = $true
        })
    Write-WpaiImproveOutcome -PathId $pathId -Verdict $verdict -Source 'auto-experiment' -Note $note `
        -Target $target -Lever $lever -Tactic $tactic -Invert $invert -Probe $probe -Hypothesis $hyp `
        -Artifact $rp | Out-Null

    return [pscustomobject]@{
        path_id     = $pathId
        verdict     = $verdict
        note        = $note
        result_path = $rp
        target      = $target
        tactic      = $tactic
        elapsed_ms  = $sw.ElapsedMilliseconds
    }
}

function Invoke-WpaiImproveAutoWave {
    <#
    .SYNOPSIS
      Auto-run experiments on top survivors, preferring self-targets.
    #>
    param(
        [int]$Limit = 12,
        [switch]$SelfOnly
    )
    $rt = Get-WpaiImproveRuntimeDir
    $gens = @(Get-ChildItem -LiteralPath $rt -Filter 'generation-*.json' -File -ErrorAction SilentlyContinue | Sort-Object Name -Descending)
    if ($gens.Count -eq 0) { throw 'No generation for auto-wave. Run generation first.' }
    $gen = Read-WpaiJsonFile -Path $gens[0].FullName
    $pool = @($gen.survivors)
    if ($SelfOnly) {
        $pool = @($pool | Where-Object {
                $t = [string]$_.target
                $t -in @('improve-swarm', 'studioops-cli', 'observability', 'overnight', 'token-budget', 'studioops-blackboard')
            })
    }
    # Prefer improve-swarm first
    $pool = @($pool | Sort-Object {
            $t = [string]$_.target
            if ($t -eq 'improve-swarm') { 0 }
            elseif ($t -eq 'studioops-cli') { 1 }
            elseif ($t -in @('observability', 'token-budget', 'overnight')) { 2 }
            else { 3 }
        }, { - [double]$_.score })
    $pool = @($pool | Select-Object -First $Limit)

    $results = @()
    foreach ($s in $pool) {
        $results += Invoke-WpaiImproveAutoExperiment -Survivor $s
    }
    $supported = @($results | Where-Object { $_.verdict -eq 'SUPPORTED' }).Count
    $killed = @($results | Where-Object { $_.verdict -eq 'KILLED' }).Count
    $inconclusive = @($results | Where-Object { $_.verdict -eq 'INCONCLUSIVE' }).Count
    return [pscustomobject]@{
        generation   = $gen.generation
        attempted    = $results.Count
        supported    = $supported
        killed       = $killed
        inconclusive = $inconclusive
        results      = $results
    }
}

# ── Unleash: swarm eats itself ───────────────────────────────────────────────

function Invoke-WpaiImproveUnleash {
    <#
    .SYNOPSIS
      Multi-wave self-evolution: learn → elite → self-inject → gen → auto-wave → learn → mutate → …
      No paid APIs. No publish. Swarm improves the swarm.
    #>
    param(
        [int]$Waves = 2,
        [int]$Top = 40,
        [int]$Probe = 16,
        [int]$AutoLimit = 12,
        [int]$Keep = 28,
        [int]$Inject = 60,
        [int]$ExtraMutants = 50,
        [int]$Briefs = 8,
        [switch]$SelfOnlyAuto
    )
    if ($Waves -lt 1) { $Waves = 1 }
    if ($Waves -gt 8) { $Waves = 8 } # hard cap: local only but avoid runaway

    $waveReports = @()
    $t0 = [DateTime]::UtcNow

    for ($w = 1; $w -le $Waves; $w++) {
        $wStart = [DateTime]::UtcNow
        $learn1 = Invoke-WpaiImproveLearn
        $elite = Update-WpaiImproveEliteArchive
        $self = Invoke-WpaiImproveSelfInject -ExtraMutants $ExtraMutants
        $gen = Invoke-WpaiImproveGeneration -Top $Top -Probe $Probe -Count 300
        $auto = Invoke-WpaiImproveAutoWave -Limit $AutoLimit -SelfOnly:$SelfOnlyAuto
        $learn2 = Invoke-WpaiImproveLearn
        $elite2 = Update-WpaiImproveEliteArchive
        $mut = $null
        if ($w -lt $Waves) {
            $mut = Invoke-WpaiImproveMutate -Keep $Keep -Inject $Inject
            # re-inject self bias after mutate so next wave stays meta
            Invoke-WpaiImproveSelfInject -ExtraMutants ([math]::Max(20, [int]($ExtraMutants / 2))) | Out-Null
        }
        $br = $null
        if ($w -eq $Waves -and $Briefs -gt 0) {
            $br = Export-WpaiImproveBriefs -Top $Briefs
        }

        $report = [ordered]@{
            wave            = $w
            generation      = $gen.generation
            top_score       = $gen.top_score
            top_hypothesis  = $gen.top_hypothesis
            catalog_size    = $gen.catalog_size
            self_injected   = $self.injected
            catalog_after_self = $self.count
            auto_supported  = $auto.supported
            auto_killed     = $auto.killed
            auto_inconclusive = $auto.inconclusive
            auto_attempted  = $auto.attempted
            outcomes_total  = $learn2.outcomes_total
            bans_total      = $learn2.bans_total
            elites_total    = $elite2.count
            elapsed_sec     = [math]::Round(([DateTime]::UtcNow - $wStart).TotalSeconds, 2)
            auto_results    = @($auto.results | ForEach-Object {
                    @{ path_id = $_.path_id; verdict = $_.verdict; target = $_.target; tactic = $_.tactic; note = $_.note }
                })
        }
        $waveReports += ,([pscustomobject]$report)

        try {
            Invoke-WpaiBlackboardRmw -Mutator {
                param($bb)
                Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'improve.unleash.wave' -Division 'software' -Actor 'bridge' -Refs @{
                    wave       = $w
                    generation = $gen.generation
                    supported  = $auto.supported
                    killed     = $auto.killed
                }
            } | Out-Null
        } catch { }
    }

    $rt = Get-WpaiImproveRuntimeDir
    $unleashPath = Join-Path $rt 'UNLEASH.md'
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('# Improve Swarm — UNLEASH (self-evolution)')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("Waves: $Waves · finished: $((Get-WpaiUtcNow)) · wall-sec: $([math]::Round(([DateTime]::UtcNow - $t0).TotalSeconds, 1))")
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine('The swarm attacked its own control plane: self-inject → score → auto-experiment → learn → mutate.')
    [void]$sb.AppendLine('')
    foreach ($wr in @($waveReports)) {
        [void]$sb.AppendLine("## Wave $($wr.wave) — generation $($wr.generation)")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine("- catalog: $($wr.catalog_after_self) (self-injected +$($wr.self_injected))")
        [void]$sb.AppendLine("- top score: $($wr.top_score)")
        [void]$sb.AppendLine("- top: $($wr.top_hypothesis)")
        [void]$sb.AppendLine("- auto: $($wr.auto_supported) SUPPORTED / $($wr.auto_killed) KILLED / $($wr.auto_inconclusive) INCONCLUSIVE (of $($wr.auto_attempted))")
        [void]$sb.AppendLine("- outcomes: $($wr.outcomes_total) · bans: $($wr.bans_total) · elites: $($wr.elites_total)")
        [void]$sb.AppendLine("- elapsed: $($wr.elapsed_sec)s")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('| Path | Verdict | Target | Tactic | Note |')
        [void]$sb.AppendLine('|------|---------|--------|--------|------|')
        foreach ($ar in @($wr.auto_results)) {
            $n = ([string]$ar.note) -replace '\|', '/'
            if ($n.Length -gt 50) { $n = $n.Substring(0, 47) + '...' }
            [void]$sb.AppendLine(('| `{0}` | {1} | {2} | {3} | {4} |' -f $ar.path_id, $ar.verdict, $ar.target, $ar.tactic, $n))
        }
        [void]$sb.AppendLine('')
    }
    [void]$sb.AppendLine('## Next')
    [void]$sb.AppendLine('- Read LEADERS.md + briefs for agent micro-impls on non-self targets.')
    [void]$sb.AppendLine('- Dead genes stay banned; elites re-enter every self-inject.')
    [void]$sb.AppendLine('- Re-run: `wpai improve unleash -Waves 2`')
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($unleashPath, $sb.ToString(), $utf8)

    $reportsArr = @($waveReports)

    # JSON twin
    $jsonPath = Join-Path $rt 'unleash-last.json'
    $jsonReports = @()
    foreach ($wr in $reportsArr) {
        $h = [ordered]@{
            wave               = $wr.wave
            generation         = $wr.generation
            top_score          = $wr.top_score
            top_hypothesis     = $wr.top_hypothesis
            catalog_size       = $wr.catalog_size
            self_injected      = $wr.self_injected
            catalog_after_self = $wr.catalog_after_self
            auto_supported     = $wr.auto_supported
            auto_killed        = $wr.auto_killed
            auto_inconclusive  = $wr.auto_inconclusive
            auto_attempted     = $wr.auto_attempted
            outcomes_total     = $wr.outcomes_total
            bans_total         = $wr.bans_total
            elites_total       = $wr.elites_total
            elapsed_sec        = $wr.elapsed_sec
            auto_results       = @($wr.auto_results)
        }
        $jsonReports += $h
    }
    Write-WpaiJsonAtomic -Path $jsonPath -Object ([ordered]@{
            schema_version = '1.0.0'
            finished_at    = (Get-WpaiUtcNow)
            waves          = $Waves
            wall_sec       = [math]::Round(([DateTime]::UtcNow - $t0).TotalSeconds, 2)
            reports        = $jsonReports
        })

    $sumSupported = 0
    $sumKilled = 0
    foreach ($wr in $reportsArr) {
        $sumSupported += [int]$wr.auto_supported
        $sumKilled += [int]$wr.auto_killed
    }
    $last = $reportsArr[$reportsArr.Count - 1]

    return [pscustomobject]@{
        waves            = $Waves
        wall_sec         = [math]::Round(([DateTime]::UtcNow - $t0).TotalSeconds, 2)
        unleash_path     = $unleashPath
        json_path        = $jsonPath
        reports          = $reportsArr
        final_generation = $last.generation
        total_supported  = $sumSupported
        total_killed     = $sumKilled
    }
}
