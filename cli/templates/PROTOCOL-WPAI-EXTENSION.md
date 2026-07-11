# WPAI control-plane extension (Protocol v2+)

Appends machine-ledger types to Council Protocol v2. Bus stays short (~400 chars non-chat). Substance on disk under `.wpai/`.

## New bus types

| type | Meaning | `path` |
|------|---------|--------|
| `approve_request` | HITL ticket awaiting Director | `.wpai/approvals/<id>.json` |
| `approve_result` | Decision notification (ticket file remains SoT) | ticket path |
| `budget` | Spend/cap notice | optional BLACKBOARD |
| `kill` | Kill switch changed | optional BLACKBOARD |
| `blackboard_sync` | Projection refresh done | `.wpai/BLACKBOARD.json` |

## Machine ledger

| Path | Role |
|------|------|
| `C:\WPAI\Workspace\.wpai\BLACKBOARD.json` | Gates, budgets, kill, projections — **single-writer RMW via `wpai` only** |
| `C:\WPAI\Workspace\.wpai\approvals\*.json` | HITL tickets (source of truth) |
| `C:\WPAI\Workspace\.wpai\plans\*-delegation.json` | Janus DelegationPlan files (never raw janus_job) |
| `C:\WPAI\Workspace\.wpai\drafts\` | Non-release drafts only |
| `C:\WPAI\Workspace\.wpai\overnight-plan.json` | Armed overnight parents |

## CLI

```powershell
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 status
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 music check -EmitTicket
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 kill set loops true
```

## Invariants

1. No unsupervised DistroKid/Bandcamp/YouTube/Gumroad publish.
2. No second task store — Janus `.aether/tasks.json` remains mutation task truth.
3. Freeform bus `task` does not create Janus tasks; only `kind: janus_job` handoffs do.
4. Overnight requires arm + mid-loop budget (round-sliced).
