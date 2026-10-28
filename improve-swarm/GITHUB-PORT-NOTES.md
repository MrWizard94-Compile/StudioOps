# Algorithms ported from GitHub crawl (self-improvement mission)

**Date:** 2026-07-11  
**Crawl store:** `C:\WPAI\Software\GitHubCodeCrawler\out\self-improvement\`  
**Policy:** Port **algorithms**, not whole files. Prefer MIT/Apache/BSD. Attribute ideas.

## What landed in `WpaiImproveSwarm.ps1`

| Algorithm | Source inspiration (license) | WPAI function |
|-----------|------------------------------|---------------|
| **UCB1 exploration** | Auer et al. via striatum (BSD-2), BTB (MIT), RL-from-scratch (MIT) | `Get-WpaiImproveGeneArmStats`, `Get-WpaiImproveUcb1Bonus` → fitness `explore_bonus` |
| **Tournament selection** | fylearn GA (MIT) pattern | `Select-WpaiImproveTournament` → mutate parent pick |
| **Crowding-inspired diversity** | NSGA-II crowding *concept* (Deb; MIT teaching impls in crawl) | `Get-WpaiImproveCrowdingBonus` → `Select-WpaiImproveDiverseTop` phase 2 |
| **Hall-of-fame elitism** | DEAP/Packt elitism *idea* (MIT) | Mutate: elite genes always kept; tournament fills remaining Keep slots |

## What we did **not** do

- Did not vendor or paste NSGA-II / DEAP / striatum modules wholesale.
- Did not enable GPL sources (filtered by crawler).
- Did not claim crawler snippets as SHIPPED product code — only algorithm inspiration.

## Validation

```powershell
pwsh -File cli\tests\wpai.tests.ps1
pwsh -File cli\wpai.ps1 improve generation -Top 20 -Probe 8
pwsh -File cli\wpai.ps1 improve review
pwsh -File cli\wpai.ps1 improve doctor
```

Record under improve outcomes after green review.
