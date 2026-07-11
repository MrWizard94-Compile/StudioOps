# Brute-Force Improve Swarm

## Philosophy (not parallel tickets)

**Brute-force improvement** is evolutionary search, not a sprint board:

1. **Diverge hard** — generate hundreds of possible / unconventional improvement *paths* (hypotheses), including ones that look stupid, inverted, or “not how we do things.”
2. **Try cheaply** — score, probe, or implement a micro-slice of many paths in parallel.
3. **Converge ruthlessly** — keep survivors by fitness (tests green, measurable delta, novelty that still works). Kill the rest.
4. **Next generation** — mutate winners, re-seed diversity, repeat.
5. **Breakthrough** — over generations, an agent lands on a non-obvious path that dominates.

What this is **not**: four careful PR lanes with safe ownership maps. That is *parallel engineering*. Useful — but different.

## Mental model

```
Path genome (hundreds)
        │
        ▼
Generation N: score / probe / micro-implement ──► Fitness ledger
        │                                              │
        └──────── promote top-K + archive rest ◄───────┘
                        │
                        ▼
              Generation N+1 (mutate winners + inject diversity)
```

Same shape as `deep_research_engine` genome evolution and idle-game “try many upgrades, keep the ones that move the number” — applied to **studio capability**.

## Commands

```powershell
# Generate / refresh path catalog (hundreds)
pwsh -File cli\wpai.ps1 improve seed -Count 300

# Run one generation: score all, probe top, write survivors
pwsh -File cli\wpai.ps1 improve generation -Top 40 -Probe 12

# Show best paths this gen
pwsh -File cli\wpai.ps1 improve leaders

# Export top paths as agent briefs (for subagent wave)
pwsh -File cli\wpai.ps1 improve briefs -Top 8
```

## Artifacts

| Path | Role |
|------|------|
| `improve-swarm/paths/catalog.jsonl` | Full path genome |
| `Workspace\.wpai\improve-swarm\generation-NNNN.json` | Per-gen scores + survivors |
| `Workspace\.wpai\improve-swarm\LEADERS.md` | Human-readable top paths |
| `Workspace\.wpai\improve-swarm\briefs\` | Ready-to-spawn agent briefs |

## Fitness (v0, no paid APIs)

| Signal | Weight | Notes |
|--------|--------|-------|
| `tests_green` | high | Probe must not break self-check |
| `measurable_hook` | high | Path names a metric (latency, steps, tokens, errors) |
| `codebase_fit` | med | Grep/path hits in real WPAI tree |
| `novelty` | med | Uncommon lever×tactic×invert combo |
| `risk_penalty` | high | Publish/money/ungated mutation → demote |
| `cost_to_try` | med | Prefer cheap probes early generations |

## HITL walls

- No DistroKid / Gumroad / ads
- No unsupervised public publish
- No second task store
- Mutation of workload repos still through Janus gate when implementing code paths

## Relation to PARALLEL-IMPROVE-PLAYBOOK

| Doc | Mode |
|-----|------|
| **This swarm** | Explore hundreds of *what to try* |
| **Parallel playbook** | Once a path wins, implement it with safe multi-agent *how* |

Breakthroughs come from the swarm. PRs come from the playbook.
