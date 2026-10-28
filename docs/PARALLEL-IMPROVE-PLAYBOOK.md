# Parallel Improve Playbook — Multi-Agent Waves

**Audience:** Director (HITL) running improve waves across WPAI repos with parallel subagents.  
**Principle:** one improve branch per repo · parallel writers only on **new** files · ordered merge · self-check before PR merge.  
**No money / no paid APIs** during improve waves unless Director explicitly arms research with budget.

---

## 1. Goals

Run a **control-plane improve wave** so multiple agents (or lanes) can ship in parallel without thrashing the same files, then merge in a safe order:

| Order | Repo | Why |
|------:|------|-----|
| 1 | **StudioOps** | Control plane CLI, operator docs, Task Scheduler, runtime installer surface |
| 2 | **Janus** (`Project-Janus`) | Mutation engine, budget gate, studio-bridge, loop hooks |
| 3 | **HellForge** | UI deck, bus, IPC that **calls** StudioOps/`wpai` — depends on stable contracts |

Never reverse this order when the change spans contracts (CLI flags, BLACKBOARD shape, bus message kinds). UI-only HellForge polish can land independently **if** it does not assume unmerged StudioOps/Janus APIs.

---

## 2. Branch model — one improve branch per repo

| Repo | Path | Improve branch pattern |
|------|------|------------------------|
| StudioOps | `C:\WPAI\Software\StudioOps` | `improve/control-plane-v2` (or `improve/<wave-slug>`) |
| Janus | `C:\WPAI\AI-Research\Janus\Project-Janus` | `improve/<wave-slug>` |
| HellForge | `C:\WPAI\Software\HellForge` | `improve/<wave-slug>` |

Rules:

1. **Exactly one open improve branch per repo** for a given wave. Do not stack `improve/a` + `improve/b` on the same repo without finishing the first PR.
2. Branch from a clean `main`/`master` (or agreed base). Name the wave once; reuse the same slug across repos when the work is coordinated.
3. **Runtime is not a repo.** Never “PR” `C:\WPAI\Workspace\.wpai` or `.hellforge` — those are installer/runtime only.
4. Agents must not force-push shared improve branches without Director ack.
5. Prefer **new files** when another agent owns hot paths (`cli/wpai.ps1`, `cli/lib/WpaiCore.ps1`, HellForge main process). Split ownership explicitly (see §3).

---

## 3. Subagent parallel pattern

### 3.1 Ownership map (avoid collisions)

| Lane | Owns (examples) | Must not rewrite without coordination |
|------|-----------------|----------------------------------------|
| **StudioOps CLI core** | `cli/wpai.ps1`, `cli/lib/*.ps1`, unit tests | Site pack scripts unless asked |
| **StudioOps ops/docs** | `docs/*` (new), `scripts/Register-*.ps1`, playbooks | Core CLI libs |
| **Janus** | `packages/*`, studio-bridge, budget gate tests | HellForge Electron main |
| **HellForge** | deck panels, bus UI, tray, IPC wrappers | StudioOps PowerShell sources |

When two agents share a repo:

- Agent A owns **existing** control-plane sources.
- Agent B creates **only new** files under `docs/` and `scripts/` (or other declared paths).
- Shared files need a single writer or a sequential handoff (“I finished wpai.ps1 — your turn”).

### 3.2 Director launch checklist

1. State the **wave slug** and target repos.
2. Assign each subagent: **repo + branch + write roots + out-of-scope**.
3. Point agents at binding docs:
   - `docs/AUTONOMOUS-AI-ARCHITECTURE.md`
   - `docs/OPERATOR-PLAYBOOK.md`
   - this playbook
4. Require: no unsupervised publish, no DistroKid/Gumroad automation, no paid cloud by default.
5. Require: self-check green before requesting merge (§5).

### 3.3 Parallel execution pattern

```
Director
  ├─ Subagent StudioOps-core   → improve/<slug>  (CLI / tests)
  ├─ Subagent StudioOps-ops    → same branch, NEW docs/scripts only
  ├─ Subagent Janus            → improve/<slug>  (engine)
  └─ Subagent HellForge        → improve/<slug>  (UI; start after contract freeze if dependent)
```

**Contract freeze:** once StudioOps CLI command surface and BLACKBOARD fields for the wave are agreed (or landed on the StudioOps improve branch), Janus and HellForge may code against that surface. If contracts are still moving, HellForge UI work should stay cosmetic or mock-only.

### 3.4 Communication

- Prefer short **bus / STATUS** notes or Director chat: “StudioOps overnight arm contract stable.”
- Do not dual-write BLACKBOARD from agents; only `wpai` RMW helpers mutate it.
- Ticket kinds and kill switches stay Director-owned.

---

## 4. Merge order (binding)

```
StudioOps  →  Janus  →  HellForge
```

### 4.1 StudioOps first

1. Self-check (§5.1).
2. Open/merge PR for `improve/<slug>`.
3. After merge, optional: reinstall/bootstrap if installer paths changed:

   ```powershell
   pwsh -File C:\WPAI\Software\StudioOps\cli\Install-WpaiStudio.ps1
   ```

4. Announce **contract version** (CLI verbs, config keys) to Janus/HellForge agents.

### 4.2 Janus second

1. Rebase/merge latest StudioOps-facing assumptions (docs or pinned CLI paths).
2. Run Janus unit/integration tests relevant to the wave (budget gate, studio sync, etc.).
3. Merge only after StudioOps improve PR is on the base branch Director uses in production paths.

### 4.3 HellForge last

1. Wire UI/IPC to **merged** `wpai` / bus behavior.
2. `npm test` (or project test script) green.
3. Manual smoke: Command Deck panels + `hf-bus` / approvals list.

### 4.4 Hotfix exception

If a critical kill-switch or budget bug spans layers, Director may cherry-pick a **minimal** fix to `main` out of order — document it in the wave notes and re-sync improve branches immediately after.

---

## 5. Self-check before PR merge

Do **not** merge an improve PR red on self-check. Scope checks to the repo being merged.

### 5.1 StudioOps

```powershell
# Control plane (preferred before any wpai/lib change)
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\Self-Check-Wpai.ps1

# Site kit (when site/assets/scripts changed)
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Self-Check.ps1

# Always useful smoke
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 status
```

Expect: unit tests pass, music check non-destructive, overnight **DryRun** ok, kill round-trip restores off, no paid network calls required.

### 5.2 Janus

```powershell
cd C:\WPAI\AI-Research\Janus\Project-Janus
# Example — adjust filters to the wave
pnpm --filter @janus/integrations exec vitest run src/wpai-budget-gate.test.ts
node packages\cli\dist\bin.js janus studio sync
```

Build CLI dist if the wave touched packages the Node bin loads.

### 5.3 HellForge

```powershell
cd C:\WPAI\Software\HellForge
npm test
```

Plus Director UI smoke: Council bus, approval surfaces, no dual BLACKBOARD writers.

### 5.4 Pre-merge Director gate (≤5 minutes)

| # | Check |
|---|--------|
| 1 | Correct repo + single improve branch; no secrets in commit |
| 2 | Self-check green for that repo |
| 3 | Merge order respected if multi-repo |
| 4 | Kill switches still clearable; overnight still **arm-required** |
| 5 | No unsupervised publish paths introduced |

---

## 6. Wave close-out

1. All three PRs merged (or explicitly deferred with reason).
2. `wpai status` shows sane budgets/kills.
3. Morning/overnight Task Scheduler tasks only registered if Director wants them — see `docs/TASK-SCHEDULER.md`.
4. Archive wave notes; delete stale local improve branches after remote merge.
5. Next wave gets a **new** slug if the previous improve branch was fully merged.

---

## 7. Anti-patterns

| Anti-pattern | Prefer |
|--------------|--------|
| Two agents editing `wpai.ps1` at once | One owner; others use new files |
| Merging HellForge IPC before StudioOps CLI lands | StudioOps → Janus → HellForge |
| Treating Workspace as a git PR target | Runtime via installer only |
| Overnight start without arm | Always `overnight arm` first (human Director) |
| “Ship now, self-check later” | Self-check is the merge gate |
| Paid research “just to verify” | DryRun / local only unless funded ticket |

---

## Related

- `docs/OPERATOR-PLAYBOOK.md` — daily HITL + overnight arm/start
- `docs/TASK-SCHEDULER.md` — morning status + optional 03:00 overnight tasks
- `docs/AUTONOMOUS-AI-ARCHITECTURE.md` — binding control-plane design
- `docs/COMPLETE-CHECKLIST.md` — design PR completion matrix
