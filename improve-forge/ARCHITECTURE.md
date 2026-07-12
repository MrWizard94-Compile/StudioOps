# Hell Forge — the one engine

**What this is:** a single local desktop cockpit (the AI‑Studio *hell‑forge‑swarm* look) over
the **real** WPAI systems that already exist. No cloud API, no web server, nothing simulated.
Every panel that the AI‑Studio mockup *faked* is wired to a real engine here.

> This document is the contract for the merge. It exists because the pieces were always meant to
> be **one system** (see `C:\WPAI\AI-Research\AUTONOMOUS-AI-ARCHITECTURE.md`), and earlier work
> accidentally grew *silos* that shadowed the real engines. Hell Forge **composes** them; it does
> not reinvent them.

---

## The real engines it composes (all confirmed on disk / running)

| Engine | Role | Where | Interface |
|--------|------|-------|-----------|
| **improve‑swarm** | Local hypothesis/falsification genome + honest reliability gate | `StudioOps\cli\lib\WpaiImproveSwarm.ps1` | `bridge.ps1` (pwsh) |
| **deep_research_engine** | Self‑improving strategy **genome** under a non‑gameable Docker gate (canary strict‑improve, reversible archive) | `AI-Research\deep_research_engine` | `python main.py` (env‑driven) + `workspace/genome_log.json`, `solutions/` |
| **JanusPrime** | The **only** thing allowed to mutate registered code — Plan→Execute→Validate→Repair→Accept, validation kernel (LSP·AST·Rules·Build), git worktrees, **SHA‑256 receipts** | `AI-Research\Janus` | `janus` CLI (`bin.js`) |
| **Smart‑Library** | Semantic long‑term **code memory** + sandboxed self‑heal | `AI-Research\Janus\Smart-Library` (`:8000`) | `janus memory query/heal`, HTTP `/seed` |
| **GitHubCodeCrawler** | License‑ + secret‑filtered open‑source harvester | `Software\GitHubCodeCrawler` | `python -m github_code_crawler mission` |
| **Ollama (Docker)** | Local models — `qwen2.5-coder:14b` (code), `deepseek-r1*` (reason) | container `ollama-engine` (`:11434`) | HTTP `/api/generate`, `/api/tags` |

---

## Panel → engine mapping (what "make the faked stuff real" means)

| AI‑Studio panel (the look kept) | Faked in the mockup | Real engine in Hell Forge |
|---|---|---|
| Header metrics (CPU/mem/furnace/nodes) | random numbers | **real** `docker`/`ollama`/`janus`/engine telemetry (`system` verb) |
| Workspace Directory + Live File Reader | static list | real bounded file tree (`files` verb) |
| Crawled Open‑Source Bits | invented insights | **GitHubCodeCrawler → Smart‑Library** harvested snippets (`crawl` verb) |
| Swarm candidates + Falsify | scripted agents | improve‑swarm measured verdicts + Ollama‑generated candidates compiled in a **Docker sandbox** |
| Apply & Deploy | direct file write + `.bak` | **Janus** `patch submit --apply` → validation receipt (never an unchecked write) |
| Forged Artifacts Archive | in‑memory list | real improve‑swarm elites + `deep_research/solutions_manifest.json` |
| Pipeline stages Scan→Crawl→Swarm→Falsify→Refine→Forged | timed animation | driven by real stage results |

---

## Honesty invariants (non‑negotiable — this is the whole point)

1. **No simulated telemetry.** If a service is down, the cockpit says so and how to start it. Numbers are measured or absent.
2. **No fabricated candidates or crawl insights.** Every card is a real engine output with provenance.
3. **Mutation only through Janus.** Applying a forged change goes through Janus's validation gate and produces a SHA‑256 receipt. Hell Forge never writes into a registered workload repo directly.
4. **Untrusted code runs only in a Docker sandbox.** Crawled/LLM‑generated code is compiled/executed inside a throwaway container, never on the host.
5. **Falsification is measured.** A candidate is `FORGED` only if it really compiles/passes in the sandbox; otherwise `INCINERATED` with the real compiler log, or `INCONCLUSIVE`.
6. **HITL for anything outward or irreversible.** Publish/deploy/money paths stay behind approval tickets per the master architecture.

---

## Process shape

```
Electron main.js ── IPC ──┐
                          ├─ bridge.ps1  (pwsh)  → improve-swarm + system/files/crawl telemetry
                          ├─ codeforge.cjs (node)→ Ollama generate → Docker falsify
                          └─ janus CLI (node)    → plan/patch/apply (+ receipts), memory query/heal
renderer (vanilla, no build) ── window.forge ──┘   AI-Studio layout, real data only
```

## Build roadmap (tracked as tasks)

1. Unified architecture spec *(this doc)*
2. Real system telemetry backbone — `system` verb + real header
3. Crawler → Smart‑Library seed pipeline — `crawl` verb + real Crawled‑Bits panel
4. Real workspace file explorer — `files` verb
5. Real code‑forge candidates — Ollama gen → Docker falsify → **Janus apply (receipt)**
6. deep_research self‑improvement control + real Forged Artifacts
7. Port the AI‑Studio layout to the vanilla cockpit, every panel bound to a real verb

Each slice ships complete and working; nothing is left stubbed, and no panel is wired to fake data.
