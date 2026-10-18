# StudioOps governance adoption and bus isolation — 2026-10-18

Constitutional law comes only from accepted `main` of
[WPAI Constitution](https://github.com/MrWizard94-Compile/Agents-Constitution).
Use `wpai-constitution`, freezing and verifying one accepted revision per
invocation. The accepted source/tool snapshot for this adoption is v6.16.4,
`0010a8353b00754fad31a30ed24327d3b6d05425`; it does not retroactively change an
already frozen invocation. Root/docs entries are project pointers, not law forks.

## Preserved scope and recovery

The two former guidance pointers now load canonical law and describe StudioOps
data/approval boundaries. Four retired guidance/archive duplicates are removed
only after exact raw recovery outside the project. Both longer archive copies
have the same SHA-256; their generic quality doctrine maps to the existing
Constitution rather than becoming new project law. The machine-local recovery
manifest records originals, hashes and semantic disposition without publishing
personal preferences or private files from historical guidance.

Website, assets, experimental/research work, control-plane product behavior,
primary branch/head and the original index are preserved. Runtime provider
cache/credential state is excluded from the preservation hash inventory and
is not copied, read for content or modified by this migration. No unrelated
unpublished work is staged or published.

## Director-approved focused repair

The previous bus test selected a temporary `HF_BUS` but the CLI still created
default Council directories and mirrored messages to default inboxes. The
director approved a focused isolation repair. All associated paths now derive
from the effective bus: `-Path` wins over `HF_BUS`, then the unchanged production
default applies. Every operation resolves afresh, so changing `HF_BUS` after
import cannot retain an earlier inbox root. Relative paths use the PowerShell
location; the provider must be FileSystem and the path must name a file.
Recipients and handoff senders used in filenames must be single valid filename
components; path separators are rejected before the affected write. Invalid
recipient input creates no bus or Council directories. This is not an OS sandbox
against a compromised filesystem or arbitrary unrelated product operations.

This uses PowerShell's provider-aware unresolved-path API, including provider
metadata, rather than requiring a pre-existing file or guessing the process
working directory. See [Microsoft's API contract](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pathintrinsics.getunresolvedproviderpathfrompspath).

The original 24 assertions are retained. Its CLI path is parameterized for
private candidates/other checkouts, and cleanup validates the exact generated
temporary directory and rejects links. A separate real-file regression suite
exercises inboxes, handoffs, status/protocol reads, exports, explicit/environment
priority, changed environment, literal bracket/space paths and rejected providers.
The unchanged original implementation is tested safely with its legacy defaults
redirected to a disposable sentinel; it must fail the new isolation checks.
No core message/parser behavior is mocked to produce passing results.

## Verification and limits

```powershell
pwsh -NoProfile -File cli/tests/hf-bus.isolation.tests.ps1
pwsh -NoProfile -File cli/tests/hf-bus.tests.ps1
python -B -W error -m unittest discover -s governance_tests -v
```

Run accepted `tools/check-adoption.py` against the actual StudioOps Git root
after integration. Source and disposable-consumer checks do not prove deployed
websites, live control-plane budgets, production approvals, agent readiness or
every installed client refreshed.

Do not substitute `scripts/Self-Check.ps1` or `cli/tests/wpai.tests.ps1` for
these fixture checks: the former posts a probe and the latter writes real
blackboard/approvals/kill state. This migration does not invoke them, install
shell profiles, publish, spend, start agents, alter operational tickets or
change the user's live Council/memory data.
