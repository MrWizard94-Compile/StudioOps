# WPAI Operator Playbook — Control Plane

**Human-directed · AI-assisted · no unsupervised publish**

## Morning HITL (≤10 minutes)

```powershell
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 status
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 approve list pending
```

1. Review pending approval tickets under `C:\WPAI\Workspace\.wpai\approvals\`.
2. For music: if package-ready ticket exists → DistroKid upload is **manual**.
3. Check kill switches and budget day/month spent.
4. Optional: HellForge Council (`Alt+C`) + `hf-bus board` for STATUS.md.

## First-time install

```powershell
pwsh -File C:\WPAI\Software\StudioOps\cli\Install-WpaiStudio.ps1
```

## Music package-ready (Weaponized Mind)

```powershell
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 music check -EmitTicket
```

- PASS + ticket → you upload DistroKid (AI disclosure + Explicit).
- Never automate DistroKid/Bandcamp/YouTube.

## Overnight coding (armed only)

```powershell
# After Orchestrator created a Janus parent task id:
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 overnight arm -ParentTaskIds task-XXXX -MaxRounds 5
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 overnight start -DryRun   # optional
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 overnight start
```

- Mid-loop cost model v0 charges every round.
- Kill: `wpai kill set loops true` stops further rounds.
- Defaults: $5/day, $40/month, 30 executor invocations/day.

## Janus job → plan (structured only)

```powershell
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 bridge plan -Job C:\path\job.json
# Review .wpai\plans\*-delegation.json then:
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 bridge plan -Job C:\path\job.json -Submit
```

## Emergency stop

```powershell
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 kill set global true
pwsh -File C:\WPAI\Software\StudioOps\cli\wpai.ps1 overnight disarm
```

## Tests

```powershell
pwsh -File C:\WPAI\Software\StudioOps\cli\tests\wpai.tests.ps1
cd C:\WPAI\Software\HellForge; npm test
```
