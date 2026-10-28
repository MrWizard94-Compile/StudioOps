# WPAI Task Scheduler — Morning Status & Overnight Start

**On-demand control plane** — no always-on Windows service. Optional scheduled tasks only.

| Task | Script | When | Command |
|------|--------|------|---------|
| `\WPAI\MorningStatus` | `scripts/Register-WpaiMorningTask.ps1` | At user logon | `wpai status` |
| `\WPAI\OvernightStart` | `scripts/Register-WpaiOvernightTask.ps1` | Daily **03:00 local** | `wpai overnight start` |

Logs land under runtime (not git):

| Task | Default log |
|------|-------------|
| Morning | `C:\WPAI\Workspace\.wpai\logs\morning-status.log` |
| Overnight | `C:\WPAI\Workspace\.wpai\logs\overnight-scheduled.log` |

Related: daily HITL steps in `docs/OPERATOR-PLAYBOOK.md`; multi-agent merge waves in `docs/PARALLEL-IMPROVE-PLAYBOOK.md`.

---

## Prerequisites

1. PowerShell 7+ (`pwsh`) on PATH.
2. Control plane installed:

   ```powershell
   pwsh -File C:\WPAI\Software\StudioOps\cli\Install-WpaiStudio.ps1
   ```

3. Logged-in user may create tasks in Task Scheduler (interactive principal).

---

## Morning status (recommended)

Runs a **read-only** snapshot at logon for the ≤10 minute morning HITL review.

```powershell
# Preview
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Register-WpaiMorningTask.ps1 -WhatIf

# Register / update
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Register-WpaiMorningTask.ps1

# Remove
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Register-WpaiMorningTask.ps1 -Unregister
```

After logon, open:

```text
C:\WPAI\Workspace\.wpai\logs\morning-status.log
```

Or re-run live:

```powershell
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 status
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 approve list pending
```

---

## Overnight start (optional) — **arm required**

Registering the 03:00 task **does not** authorize work. `overnight start` is **fail-closed** unless Director has armed:

```powershell
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 overnight arm -ParentTaskIds task-XXXX -MaxRounds 5
```

Arm expires; kill switches and budgets still apply. Re-arm each night you want work. See `docs/OPERATOR-PLAYBOOK.md`.

```powershell
# Preview
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Register-WpaiOvernightTask.ps1 -WhatIf

# Register daily 03:00 local
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Register-WpaiOvernightTask.ps1

# Custom time (local)
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Register-WpaiOvernightTask.ps1 -Time 02:30

# Remove
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Register-WpaiOvernightTask.ps1 -Unregister
```

**Emergency stop**

```powershell
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 kill set loops true
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 overnight disarm
# and/or:
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Register-WpaiOvernightTask.ps1 -Unregister
```

---

## Verify tasks

```powershell
Get-ScheduledTask -TaskPath '\WPAI\' | Format-Table TaskName, State, TaskPath
Get-ScheduledTaskInfo -TaskName 'MorningStatus' -TaskPath '\WPAI\'
Get-ScheduledTaskInfo -TaskName 'OvernightStart' -TaskPath '\WPAI\'
```

Or: Task Scheduler MMC → Task Scheduler Library → **WPAI**.

---

## Design notes

| Topic | Behavior |
|-------|----------|
| Process model | Still on-demand CLI; scheduler only invokes `wpai` |
| Money / publish | No DistroKid/Gumroad/ads; overnight respects arm + budget + kill |
| Principal | Current user, interactive, limited (not SYSTEM) |
| `-WhatIf` | Both register scripts support `SupportsShouldProcess` |
| `-Unregister` | Idempotent-friendly: missing task → warning, exit success |
| Overnight log | Append mode (history); morning log overwrite each logon |
| Parallel improve | New ops files only — safe for multi-agent waves (`PARALLEL-IMPROVE-PLAYBOOK.md`) |

---

## Uninstall all WPAI scheduled tasks

```powershell
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Register-WpaiMorningTask.ps1 -Unregister
pwsh -NoProfile -File C:\WPAI\Software\StudioOps\scripts\Register-WpaiOvernightTask.ps1 -Unregister
```
