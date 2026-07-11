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
    [switch]$SelfOnly
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
        default { Out-Json ([ordered]@{ ok = $false; error = "unknown verb: $Verb" }) }
    }
} catch {
    Out-Json ([ordered]@{ ok = $false; error = $_.Exception.Message })
}
