# Brute-Force Improve Swarm

## Philosophy (not parallel tickets)

**Brute-force improvement** is evolutionary search, not a sprint board:

1. **Diverge hard** — generate hundreds of possible / unconventional improvement *paths* (hypotheses), including ones that look stupid, inverted, or “not how we do things.”
2. **Try cheaply** — score, probe, or implement a micro-slice of many paths in parallel.
3. **Converge ruthlessly** — keep survivors by fitness (tests green, measurable delta, novelty that still works). Kill the rest.
4. **Learn** — ingest kills + experiment results into an outcomes ledger; ban dead genes; boost supported genes.
5. **Next generation** — mutate winners (skip bans), re-seed diversity, repeat.
6. **Breakthrough** — over generations, an agent lands on a non-obvious path that dominates.

What this is **not**: four careful PR lanes with safe ownership maps. That is *parallel engineering*. Useful — but different.

## Mental model

```
Path genome (hundreds)
        │
        ▼
Generation N: score / probe / micro-implement ──► Fitness ledger
        │                                              │
        │         outcomes.jsonl ← kills / results     │
        │                │                             │
        │                ▼                             │
        │           bans.json (dead genes)             │
        │                │                             │
        └──────── promote diverse top-K ◄──────────────┘
                        │
                        ▼
              Generation N+1 (mutate winners + inject diversity − bans)
```

Same shape as `deep_research_engine` genome evolution and idle-game “try many upgrades, keep the ones that move the number” — applied to **studio capability**.

## Commands

```powershell
# Generate / refresh path catalog (hundreds); skips banned genes when bans exist
pwsh -File cli\wpai.ps1 improve seed -Count 300

# Run one generation: score all, probe top, diversity-select survivors
pwsh -File cli\wpai.ps1 improve generation -Top 40 -Probe 12

# Show best paths this gen
pwsh -File cli\wpai.ps1 improve leaders

# Export top paths as agent briefs (for subagent wave)
pwsh -File cli\wpai.ps1 improve briefs -Top 8

# After experiments: record a verdict (or drop kill md / result.json)
pwsh -File cli\wpai.ps1 improve record -PathId path-abc -Verdict KILLED -Note "why"
pwsh -File cli\wpai.ps1 improve record -PathId path-xyz -Verdict SUPPORTED -Note "metric delta"

# Ingest kills/ + experiments/**/result.json → outcomes + gene bans
pwsh -File cli\wpai.ps1 improve learn

# Mutate catalog from last survivors (ban-aware)
pwsh -File cli\wpai.ps1 improve mutate -Keep 30 -Inject 80

# One-shot cycle: learn → mutate → generation
pwsh -File cli\wpai.ps1 improve run -Top 40 -Probe 16 -Briefs 8

# Swarm eats itself (meta-evolution)
pwsh -File cli\wpai.ps1 improve self-inject          # curated improve-swarm recipes
pwsh -File cli\wpai.ps1 improve auto -Limit 12 -SelfOnly
pwsh -File cli\wpai.ps1 improve unleash -Waves 2 -AutoLimit 14 -Briefs 10 -SelfOnly

# Inspect learning state
pwsh -File cli\wpai.ps1 improve status
pwsh -File cli\wpai.ps1 improve outcomes
pwsh -File cli\wpai.ps1 improve bans
pwsh -File cli\wpai.ps1 improve learning
pwsh -File cli\wpai.ps1 improve elite
```

## Artifacts

| Path | Role |
|------|------|
| `improve-swarm/paths/catalog.jsonl` | Full path genome |
| `improve-swarm/experiments/<path-id>/result.json` | Experiment verdicts (`SUPPORTED` / `KILLED`) |
| `Workspace\.wpai\improve-swarm\generation-NNNN.json` | Per-gen scores + survivors |
| `Workspace\.wpai\improve-swarm\LEADERS.md` | Human-readable top paths |
| `Workspace\.wpai\improve-swarm\briefs\` | Ready-to-spawn agent briefs |
| `Workspace\.wpai\improve-swarm\kills\` | Fast-kill notes (`path-….md`) |
| `Workspace\.wpai\improve-swarm\outcomes.jsonl` | Append-only learning ledger |
| `Workspace\.wpai\improve-swarm\bans.json` | Dead genes (tactic×lever, path ids) |
| `Workspace\.wpai\improve-swarm\LEARNING.md` | Human summary of bans + supported genes |
| `Workspace\.wpai\improve-swarm\elite.json` | Hall-of-fame SUPPORTED genes (survive mutate) |
| `Workspace\.wpai\improve-swarm\UNLEASH.md` | Multi-wave self-evolution report |

## Fitness (v2, no paid APIs)

| Signal | Weight | Notes |
|--------|--------|-------|
| `codebase_fit` | med | Path hits in real WPAI tree |
| `novelty` | med | Uncommon lever×tactic×invert combo |
| `measurable_hook` | high | Path names a metric (latency, tokens, reliability…) |
| `probe_ok` | high | Cheap local probe must pass |
| `learn_boost` | med | **Evidence-weighted** (measured > strong > structural > weak); diminishing returns |
| `explore_bonus` | low | Untested genes get a small lift |
| `stagnation_pen` | med | Leaders that repeat without strong evidence demote |
| `jitter` | tiny | Stable path-id jitter breaks score plateaus |
| `ban` | hard | Banned tactic×lever or path_id → near-zero score |
| `risk_penalty` | high | Publish/money/ungated mutation → demote |
| `cost_to_try` | med | Prefer cheap probes early generations |
| `diversity` | selection | Survivors prefer distinct target/lever/tactic |

Auto-experiments default to **INCONCLUSIVE**, not free SUPPORTED. Presence-only checks are structural at best. See `META.md` for kill rate + score variance.

## Learning rules

1. **Kills** under `kills/path-….md` → outcome `KILLED`.
2. **Experiments** under `experiments/**/result.json` with `verdict` → outcome.
3. **Manual** via `wpai improve record`.
4. After `learn`, any `tactic×lever` with ≥1 kill and not more supports becomes a **ban**.
5. **Mutate/seed** skip banned genes; **fitness** crushes their score so they cannot re-win.
6. Example from gen2: `raise-context×latency` is a dead end (context caps already tight).

## HITL walls

- No DistroKid / Gumroad / ads
- No unsupervised public publish
- No second task store
- Mutation of workload repos still through Janus gate when implementing code paths

## Relation to PARALLEL-IMPROVE-PLAYBOOK

| Doc | Mode |
|-----|------|
| **This swarm** | Explore hundreds of *what to try* + learn what died |
| **Parallel playbook** | Once a path wins, implement it with safe multi-agent *how* |

Breakthroughs come from the swarm. PRs come from the playbook.
