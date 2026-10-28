"""Read-only governance contracts; operational commands are never executed."""
from __future__ import annotations

import json
import os
import re
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LINK_ROOT = Path(os.environ.get("STUDIOOPS_GOVERNANCE_LINK_ROOT", str(ROOT))).resolve()
CANONICAL = "https://github.com/MrWizard94-Compile/Agents-Constitution"


def powershell(script: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ.copy()
    environment["STUDIOOPS_GOVERNANCE_CANDIDATE"] = str(ROOT)
    environment["STUDIOOPS_GOVERNANCE_LINK_ROOT"] = str(LINK_ROOT)
    return subprocess.run(
        ["pwsh", "-NoProfile", "-NonInteractive", "-Command", script],
        env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, encoding="utf-8", timeout=20,
    )


class GovernanceEntryTests(unittest.TestCase):
    def test_root_and_docs_entries_load_canonical_law(self):
        for relative in ("AGENTS.md", "docs/AGENTS.md"):
            with self.subTest(path=relative):
                text = (ROOT / relative).read_text(encoding="utf-8-sig")
                self.assertIn(CANONICAL, text)
                self.assertIn("wpai-constitution", text)
                self.assertIn("accepted", text)
                self.assertNotIn("AGENTS " + "Constitution/", text)
                self.assertNotIn("verify-" + "pack.ps1", text)

    def test_project_entry_preserves_operational_approval_and_state_boundaries(self):
        text = (ROOT / "AGENTS.md").read_text(encoding="utf-8-sig")
        for term in ("freeze", "SOURCE", "same revision", "no second task store",
                     "no unsupervised", "budgets", "kill switches", "overnight arming",
                     "Self-Check.ps1", "real Council probe", "wpai.tests.ps1",
                     "blackboard", "approval tickets", "not authorization",
                     "separate operational", "disposable"):
            with self.subTest(term=term):
                self.assertIn(term, text)

    def test_retired_working_tree_guidance_is_not_discoverable(self):
        for relative in ("SOUL.md", "docs/SOUL.md",
                         "SOUL.md.legacy-pre-pack-20260727-205752",
                         "docs/SOUL.md.legacy-pre-pack-20260727-205752"):
            with self.subTest(path=relative):
                self.assertFalse((ROOT / relative).exists())

    def test_changed_instruction_links_resolve_within_the_project(self):
        for relative in ("AGENTS.md", "docs/AGENTS.md", "README.md", "docs/GOVERNANCE-ADOPTION.md"):
            text = (ROOT / relative).read_text(encoding="utf-8-sig")
            for link in re.findall(r"(?<!!)\[[^\]]*\]\(([^)]+)\)", text):
                target = link.strip("<>").split("#", 1)[0]
                if not target or re.match(r"[a-z]+://", target):
                    continue
                with self.subTest(path=relative, target=target):
                    candidate = ((ROOT / relative).parent / target).resolve()
                    fallback = ((LINK_ROOT / relative).parent / target).resolve()
                    self.assertTrue(candidate.is_relative_to(ROOT))
                    self.assertTrue(fallback.is_relative_to(LINK_ROOT))
                    self.assertTrue(candidate.is_file() or fallback.is_file())

    def test_default_council_paths_are_unchanged_without_creating_them(self):
        result = powershell(r"""
$ErrorActionPreference = 'Stop'
Remove-Item Env:HF_BUS -ErrorAction SilentlyContinue
. (Join-Path $env:STUDIOOPS_GOVERNANCE_CANDIDATE 'cli/hf-bus.ps1')
Get-HfCouncilPaths | ConvertTo-Json -Compress
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        actual = json.loads(result.stdout)
        root = "C:\\WPAI\\Workspace\\.hellforge"
        expected = {"Root": root, "Bus": root + "\\bus.jsonl", "Handoffs": root + "\\handoffs",
                    "Inbox": root + "\\inbox", "Status": root + "\\STATUS.md",
                    "Protocol": root + "\\PROTOCOL.md", "Exports": root + "\\exports"}
        self.assertEqual(actual, expected)

    def test_original_suite_is_parseable_portable_and_has_guarded_cleanup(self):
        script = (ROOT / "cli/tests/hf-bus.tests.ps1").read_text(encoding="utf-8-sig")
        for term in ("param([string]$CliPath", ". $CliPath", "-File $CliPath", "GetFullPath",
                     "Refusing cleanup", "ReparsePoint", "-LiteralPath $cleanupTarget"):
            with self.subTest(term=term):
                self.assertIn(term, script)
        result = powershell(r"""
$ErrorActionPreference = 'Stop'
$path = Join-Path $env:STUDIOOPS_GOVERNANCE_CANDIDATE 'cli/tests/hf-bus.tests.ps1'
$tokens = $null
$parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$parseErrors)
if ($parseErrors.Count) { throw ($parseErrors.Message -join '; ') }
$assertions = @($ast.FindAll({ param($node) $node -is [Management.Automation.Language.CommandAst] -and $node.GetCommandName() -like 'Assert-*' },$true))
[pscustomobject]@{ assertions = $assertions.Count; parseErrors = $parseErrors.Count } | ConvertTo-Json -Compress
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), {"assertions": 24, "parseErrors": 0})

    def test_readme_distinguishes_fixture_tests_from_live_operations(self):
        text = (ROOT / "README.md").read_text(encoding="utf-8-sig")
        for term in ("Council bus CLI", "HITL approvals", "no second task store",
                     "HF_BUS", "associated state", "Relative paths", "Disposable tests",
                     "hf-bus.isolation.tests.ps1", "posts a Council probe",
                     "not an isolated unit test", "separate operational authority"):
            with self.subTest(term=term):
                self.assertIn(term, text)


if __name__ == "__main__":
    unittest.main()
