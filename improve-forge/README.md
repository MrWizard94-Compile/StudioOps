# Hell Forge Swarm (local)

The **Hell Forge Swarm** UI merged with the **WPAI improve-swarm** engine, as a local desktop
app. No web server. No Gemini. **No API key.** Every "candidate" is falsified by the local
PowerShell engine — measured `SUPPORTED`, `KILLED` (with counterexample), or `INCONCLUSIVE`.
Nothing is simulated.

This replaces the old `hell-forge-swarm` web app's fake "double-incineration compiler sandbox"
(random metrics + `checkTypeScriptCompilationSim`) with the real, honest engine.

## What it does
- **Ignite Swarm** → runs a real wave: score the path genome → auto-experiments (real
  falsification) → learn. Candidates show up with their true verdicts.
- **Run Doctor** → the reliability gate: runs the real unit suite + property checks, reports
  `RELIABLE` / `NOT RELIABLE` honestly.
- **Property Probe** → randomized falsification of the core invariants (ban robustness, fitness
  bounds, determinism, gene-key stability).
- **Forged Artifacts** → the elite hall-of-fame (survivors of real falsification).

Live metrics (outcomes / elites / bans / kills / generation) are **real** — read from the engine,
not `Math.random()`.

## Architecture
```
renderer/ (vanilla UI, no build step)
      │  window.forge.*  (contextBridge)
preload.js
      │  ipcRenderer.invoke
main.js (Electron main)  ──spawn pwsh──▶  bridge.ps1
                                              │  dot-sources ../cli/lib/Wpai*.ps1
                                              ▼
                                   the WPAI improve-swarm engine  →  JSON
```
`bridge.ps1` loads the exact libraries `../cli/wpai.ps1` loads, so it stays in lockstep with the
engine. It must live in `StudioOps/improve-forge/` (next to `StudioOps/cli/`).

## Prerequisites
- **Node.js** (for Electron)
- **PowerShell 7** (`pwsh`) on PATH
- The StudioOps improve-swarm engine present at `../cli/lib/` (it is, in this repo)

## Run
```bash
npm install      # fetches electron
npm start        # launches the desktop app
```
Sanity-check without Electron: `pwsh -File bridge.ps1 status` (prints JSON).

*AI is in the name; the wizard is in the work. The forge does not lie about what it forged.*
