# Real Breakthroughs (post-purge)

Trash removed: unit-test pollution, rubber-stamp auto supports (“CLI help exists”, “functions present”), false bans from diversity bugs, duplicate gene supports.

## Shipped / falsified (keep forever)

| Class | Path | Verdict | Why it matters |
|-------|------|---------|----------------|
| `kill:raise-context×latency` | `path-6ee11461507d` | **KILLED** | Expanding context does **not** improve Janus loop latency; caps already tight. Permanent gene ban. |
| `ship:blackboard-integrity-doctor` | `path-8e633381189e` | SUPPORTED | BLACKBOARD verify/doctor + concurrent kill_switch.research hold. Foundation for automation safety. |
| `ship:overnight-dry-before-arm` | `path-7d61dc66f9c7` | SUPPORTED | Scripted dry gate before overnight arm; bus-not-call determinism. |
| `ship:bus-prestige-archive` | `path-ac4bacaf07a8` | SUPPORTED | Bus prestige archive path without chat spam. |
| `ship:local-ollama-measure-first` | `path-a8398d344cf1` | SUPPORTED | Measure local Ollama first; skip if down — don’t block overnight. |
| `ship:overnight-chaos-kill-gate` | `path-e136eb2c9be0` | SUPPORTED | Kill switch blocks overnight when set (chaos preflight). |
| `ship:janus-double-entry-charge` | `path-bb093e1445e8` | SUPPORTED | Budget charge double-entry tests / reliability fuzz path. |

## Measured system properties (one elite each)

| Class | Meaning |
|-------|---------|
| `measured:outcomes-ledger-idempotent` | Outcomes append grows; dedupe holds. |
| `measured:budget-ledger-balanced` | Budget ledger double-entry balances. |
| `measured:kill-switch-rmw` | Setting loops kill actually activates. |
| `measured:ban-signal-in-boost-map` | Boost map carries negative signal for banned genes. |

## Trash explicitly discarded

- `path-testban*`, `path-selftest*`, `path-autochk*` unit-test pollution  
- Structural auto: “self-swarm v2 surface complete”, “CLI help surface”, “catalog present”  
- False bans: `fail-closed×reliability`, `fail-closed×`, `property-test×reliability` (diversity bug)  
- Duplicate SUPPORTED noise (20× double-entry×throughput, etc.)

## Reliability gate

```powershell
wpai improve purge
wpai improve doctor   # must print RELIABLE
```

Criteria: diversity multi-target, fail-closed auto SUPPORTS when ban holds, raise-context×latency stays banned, no test pollution, elites = breakthrough classes only.
