// Janus workload detection + job staging.
//
// Hell Forge must never mutate a REGISTERED Janus workload directly (studio HITL doctrine +
// the #1 architecture invariant). For those targets it stages a complete, ready-to-run Janus
// job — a delegation plan (mirroring Janus/agent-tools/*/plan.json), the candidate file, and
// the exact command sequence — so a human runs it through the validation-receipt gate. It does
// NOT auto-fire `patch submit --apply`: unsupervised mutation of registered code would breach
// the HITL wall.

"use strict";
const fs = require("fs");
const path = require("path");

const JANUS_ROOT = "C:\\WPAI\\AI-Research\\Janus";
const JANUS_REGISTRY = path.join(JANUS_ROOT, "workloads", "registry.json");

// If an absolute file path lives under a registered Janus workload, return that workload.
function janusWorkloadFor(absPath) {
  let reg;
  try { reg = JSON.parse(fs.readFileSync(JANUS_REGISTRY, "utf8")); }
  catch (e) { return null; }
  const target = path.resolve(absPath).toLowerCase();
  for (const w of reg.workloads || []) {
    if (!w.local_root) continue; // skip repo-only / archived entries
    const wroot = path.resolve(JANUS_ROOT, w.local_root);
    const wl = wroot.toLowerCase();
    if (target === wl || target.startsWith(wl + path.sep)) {
      return { id: w.id, profile: w.validation_profile, root: wroot, status: w.status };
    }
  }
  return null;
}

// Stage a ready-to-run Janus job for a registered-workload target. Returns a descriptor;
// writes plan.json + candidate + INSTRUCTIONS.md under <appDir>/forge/janus-jobs/.
function stageJanusJob(wl, absPath, code, instruction, appDir) {
  const rel = path.relative(wl.root, absPath).split(path.sep).join("/");
  const stamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
  const jobDir = path.join(appDir, "forge", "janus-jobs", `${wl.id}-${stamp}`);
  fs.mkdirSync(jobDir, { recursive: true });

  const obj = instruction || `Apply Hell Forge candidate to ${rel}`;
  const plan = {
    parent: {
      assignee: "claude",
      validation_profile: wl.profile,
      context_refs: ["doc:claude", "doc:handoff-protocol"],
      spec: {
        objective: `Hell Forge candidate for ${wl.id}: ${obj}`,
        constraints: [`All mutations via ${wl.profile} gate`, "No stubs or TODOs", "Zero build warnings"],
        files_in_scope: [rel],
        acceptance_criteria: [`Patch accepted under ${wl.profile} with a receipt`],
      },
    },
    children: [
      {
        assignee: "grok",
        patch_mode: "manual",
        task: {
          workload: wl.id,
          validation_profile: wl.profile,
          context_refs: ["doc:claude", "doc:handoff-protocol", "aether:patch_mode:manual"],
          spec: {
            objective: obj,
            constraints: ["No stubs or TODOs", "Zero build warnings", "Preserve public behavior and exports"],
            files_in_scope: [rel],
            acceptance_criteria: [`${rel} updated`, "Validation gate passes", "Task accepted with a receipt"],
          },
        },
      },
    ],
    provision: { auto_worktree: true, auto_prepare: true },
  };
  fs.writeFileSync(path.join(jobDir, "plan.json"), JSON.stringify(plan, null, 2), "utf8");

  const ext = path.extname(absPath) || ".txt";
  const candidateName = "candidate" + ext;
  fs.writeFileSync(path.join(jobDir, candidateName), code, "utf8");

  const planPath = path.join(jobDir, "plan.json");
  const instructions =
    `# Staged Janus job — ${wl.id} (${wl.profile})\n\n` +
    `Target (relative to workload root): \`${rel}\`\n` +
    `Candidate contents: \`${candidateName}\`\n\n` +
    `Hell Forge does NOT mutate registered workloads directly (studio HITL doctrine).\n` +
    `Run this job in the Janus workspace to apply it through the validation-receipt gate:\n\n` +
    "```powershell\n" +
    `cd ${JANUS_ROOT}\n` +
    `janus orchestrate plan -f "${planPath}"        # prints parentId + childId\n` +
    `janus orchestrate provision -t <parentId>       # provision the worktree\n` +
    `# Build patch.json (task_id = <childId>), embedding the contents of ${candidateName}:\n` +
    `#   { "task_id": "<childId>", "allow_overwrite": true,\n` +
    `#     "files": [ { "path": "${rel}", "content": <${candidateName} contents> } ] }\n` +
    `janus patch submit -f patch.json                # dry-run validate\n` +
    `janus patch submit -f patch.json --apply        # apply to worktree + write receipt\n` +
    `janus seed -t <childId>                          # seed the accepted pattern\n` +
    "```\n";
  fs.writeFileSync(path.join(jobDir, "INSTRUCTIONS.md"), instructions, "utf8");

  return {
    ok: true,
    staged: true,
    registered: true,
    workload: wl.id,
    profile: wl.profile,
    rel,
    jobDir,
    note:
      `"${rel}" is registered Janus workload "${wl.id}" (${wl.profile}). ` +
      `Hell Forge won't mutate registered code directly — staged a ready Janus job at ${jobDir}. ` +
      `Run it in the Janus workspace to apply through the validation-receipt gate.`,
  };
}

module.exports = { janusWorkloadFor, stageJanusJob, JANUS_ROOT, JANUS_REGISTRY };
