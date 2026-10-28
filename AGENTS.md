# StudioOps project entry

The accepted `main` of
[WPAI Constitution](https://github.com/MrWizard94-Compile/Agents-Constitution)
alone owns constitutional law. Use `wpai-constitution`: freeze and verify one
accepted commit, then read its SKILL, SOURCE manifest, always-load set and
applicable law from that same revision. Generated mirrors are distributions,
not authority. Do not vendor a law pack here.

## Project context and authority

Read [README](README.md), [operator playbook](docs/OPERATOR-PLAYBOOK.md) and
[governance adoption](docs/GOVERNANCE-ADOPTION.md). This Windows/PowerShell studio
kit contains owned static sites, the Council bus and a WPAI control plane.
Preserve existing website content, experimental work, assets and runtime state.

The product invariants remain: no second task store and no unsupervised
publishing, spending or distribution. The human director controls approval
tickets, budgets, kill switches and overnight arming. Reading a command in
these documents is not authorization to execute it. Do not deploy, upload,
install into a shell profile, invoke agents or modify operational approvals
as a side effect of onboarding or testing.

## Verification and data boundaries

PowerShell parsing is read-only. The focused bus suites use disposable state:

```powershell
pwsh -NoProfile -File cli/tests/hf-bus.isolation.tests.ps1
pwsh -NoProfile -File cli/tests/hf-bus.tests.ps1
python -B -W error -m unittest discover -s governance_tests -v
```

`HF_BUS` or an explicit `-Path` selects the bus and associated Council root:
inboxes, handoffs, status, protocol and default exports follow the selected bus.
Without either override, production remains under
`C:\WPAI\Workspace\.hellforge\`. A relative path follows the PowerShell
location. Tests must validate their exact disposable cleanup targets.

Do not run `scripts/Self-Check.ps1` as a harmless governance check: it posts a
real Council probe unless the whole environment has been isolated. Do not run
`cli/tests/wpai.tests.ps1` as an isolated unit test: it writes the real
blackboard, approval tickets and kill state under
`C:\WPAI\Workspace\.wpai\`. Those workflows require separate operational
authority and a verified disposable environment.

Inspect script side effects before running installers, packers, optimizers,
self-checks or control-plane commands. A clean source audit or fixture result
does not prove deployed site behavior, live approvals, budget enforcement,
provider readiness or every-client instruction refresh.
