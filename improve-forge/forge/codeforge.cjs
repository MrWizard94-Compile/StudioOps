// REAL code-forge — everything the AI-Studio mockup faked, made real. No cloud API.
//   generate:  local Ollama (qwen2.5-coder in the ollama-engine Docker container)
//   falsify:   real `tsc --noEmit` inside a throwaway Docker sandbox (node:20-alpine)
//   apply:     write file + .bak backup / restore
// CLI:  node codeforge.cjs <file.ts> "<instruction>"   (generates + falsifies, prints verdict)

"use strict";
const http = require("http");
const { spawn } = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");
const memory = require("./memory.cjs"); // read path into the crawled Smart-Library corpus

const OLLAMA = {
  host: process.env.HFS_OLLAMA_HOST || "127.0.0.1",
  port: Number(process.env.HFS_OLLAMA_PORT || 11434),
  // qwen2.5:7b is ~2x faster than the 14b coder on modest hardware and still writes solid
  // code; override with HFS_MODEL (e.g. qwen2.5-coder:7b) for the best code quality.
  model: process.env.HFS_MODEL || "qwen2.5:7b",
};
const SANDBOX_IMAGE = process.env.HFS_SANDBOX_IMAGE || "node:20-alpine";
const NPM_CACHE_VOL = "hfs-npm-cache"; // persistent volume so tsc isn't re-downloaded every run

// ---- Ollama generation (local, no key) ----
function ollamaGenerate(prompt, { num_predict = 2048, temperature = 0.2, timeoutMs = 300000 } = {}) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({
      model: OLLAMA.model, prompt, stream: false, think: false,
      options: { temperature, num_predict },
    });
    const req = http.request(
      { host: OLLAMA.host, port: OLLAMA.port, path: "/api/generate", method: "POST",
        headers: { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(body) } },
      (res) => {
        let data = "";
        res.on("data", (d) => (data += d));
        res.on("end", () => {
          try {
            const j = JSON.parse(data);
            if (j.error) return reject(new Error("ollama: " + j.error));
            resolve({ text: j.response || "", ms: Math.round((j.total_duration || 0) / 1e6) });
          } catch (e) { reject(new Error("ollama bad JSON: " + e.message)); }
        });
      }
    );
    req.on("error", (e) => reject(new Error("ollama unreachable (" + OLLAMA.host + ":" + OLLAMA.port + "): " + e.message)));
    req.setTimeout(timeoutMs, () => req.destroy(new Error("ollama timeout")));
    req.write(body);
    req.end();
  });
}

function extractCode(text) {
  const blocks = [...text.matchAll(/```(?:[a-zA-Z0-9]+)?\r?\n([\s\S]*?)```/g)];
  if (blocks.length) return blocks[blocks.length - 1][1].trim();
  return text.trim();
}

async function generateCandidate(fileContent, instruction, ext = "ts", contextBlock = "") {
  const lang = ext === "tsx" || ext === "jsx" ? "tsx" : ext;
  const prompt =
    contextBlock +
    `You are a senior engineer. Rewrite the file below to: ${instruction}.\n` +
    `Preserve behavior and public exports. Return ONLY the complete corrected file inside a single ` +
    "```" + lang + " code block, with no commentary before or after.\n\n" +
    "```" + lang + "\n" + fileContent + "\n```";
  const { text, ms } = await ollamaGenerate(prompt);
  return { code: extractCode(text), model: OLLAMA.model, gen_ms: ms };
}

// Pull the most relevant snippets from the crawled Smart-Library corpus. Fail-open: context is
// an enhancement, so a down/empty library never blocks a forge.
async function getMemoryRefs(instruction, ext, max = 3) {
  try {
    const { slices } = await memory.queryContext(`${instruction} (${ext})`, { limit: max, maxChars: 2600 });
    return slices.slice(0, max);
  } catch (e) {
    return [];
  }
}

// ---- Real, language-aware falsification in a throwaway Docker sandbox ----
// Returns { ok: true|false|null, stage, exit, log }:
//   ok=true  -> passed (compiles / parses clean)        -> FORGED
//   ok=false -> failed (real compiler/parser error log) -> INCINERATED
//   ok=null  -> no sandbox profile for this language     -> INCONCLUSIVE (never a fake pass)
function sandboxProfile(ext) {
  const e = String(ext || "").toLowerCase();
  if (e === "ts")
    return { image: "node:20-alpine", file: "candidate.ts", npm: true,
      shell: "npx -y -p typescript@5 tsc --noEmit --strict --skipLibCheck candidate.ts" };
  if (e === "tsx" || e === "jsx")
    return { image: "node:20-alpine", file: "candidate." + e, npm: true,
      shell: `npx -y -p typescript@5 tsc --noEmit --strict --skipLibCheck --jsx react-jsx candidate.${e}` };
  if (e === "js" || e === "cjs" || e === "mjs")
    return { image: "node:20-alpine", file: "candidate." + e, npm: false,
      shell: `node --check candidate.${e}` };
  if (e === "py")
    return { image: "python:3.11-alpine", file: "candidate.py", npm: false,
      shell: "python -m py_compile candidate.py && echo OK" };
  return null;
}

function falsifyInSandbox(code, ext = "ts", { timeoutMs = 120000 } = {}) {
  return new Promise((resolve) => {
    const prof = sandboxProfile(ext);
    if (!prof) {
      return resolve({ ok: null, stage: "unsupported", exit: null, log: `no Docker sandbox profile for .${ext} — verdict withheld` });
    }
    let dir;
    try { dir = fs.mkdtempSync(path.join(os.tmpdir(), "hfs-")); }
    catch (e) { return resolve({ ok: false, stage: "setup", exit: null, log: e.message }); }
    fs.writeFileSync(path.join(dir, prof.file), code, "utf8");
    const args = ["run", "--rm", "--network", "bridge", "-v", `${dir}:/work`];
    if (prof.npm) args.push("-v", `${NPM_CACHE_VOL}:/root/.npm`); // persist npm cache so tsc isn't re-fetched
    args.push("-w", "/work", prof.image, "sh", "-c", prof.shell);
    let out = "", done = false;
    const dk = spawn("docker", args, { windowsHide: true });
    const timer = setTimeout(() => { if (!done) { try { dk.kill("SIGKILL"); } catch (e) {} } }, timeoutMs);
    dk.stdout.on("data", (d) => (out += d.toString()));
    dk.stderr.on("data", (d) => (out += d.toString()));
    dk.on("error", (e) => finish({ ok: false, stage: "docker", exit: null, log: "docker error: " + e.message }));
    dk.on("close", (code2) =>
      finish({ ok: code2 === 0, stage: "compile", exit: code2, log: out.trim().slice(-2500) || "(clean)" })
    );
    function finish(r) {
      if (done) return; done = true; clearTimeout(timer);
      try { fs.rmSync(dir, { recursive: true, force: true }); } catch (e) {}
      resolve(r);
    }
  });
}

// ---- Apply / restore (real writes, with backup) ----
function applyWithBackup(filePath, code) {
  const bak = filePath + ".bak";
  fs.writeFileSync(bak, fs.readFileSync(filePath, "utf8"));
  fs.writeFileSync(filePath, code, "utf8");
  return { ok: true, backup: path.basename(bak) };
}
function restoreBackup(filePath) {
  const bak = filePath + ".bak";
  if (!fs.existsSync(bak)) return { ok: false, error: "no backup" };
  fs.writeFileSync(filePath, fs.readFileSync(bak, "utf8"));
  fs.unlinkSync(bak);
  return { ok: true };
}

// Orchestrate one candidate: generate -> falsify. `onProgress(stage)` is called with the
// real milestones (generating / generated / falsifying / verdict) so a UI pipeline can
// reflect actual phases instead of a timed animation.
async function forgeOne(fileContent, instruction, ext = "ts", onProgress = () => {}, { useMemory = true } = {}) {
  // Close the crawler loop: consult the harvested corpus for relevant patterns and feed them
  // to the model as reference context, so crawled "game-changing code" measurably shapes output.
  let refs = [];
  let contextBlock = "";
  if (useMemory) {
    onProgress({ stage: "memory", detail: "querying the crawled library" });
    refs = await getMemoryRefs(instruction, ext);
    if (refs.length) {
      contextBlock =
        "Reference patterns from our crawled open-source library (adapt what's useful, don't copy blindly):\n" +
        refs.map((s, i) => "--- ref " + (i + 1) + " ---\n" + s).join("\n") +
        "\n\n";
      onProgress({ stage: "memory", detail: refs.length + " ref(s) pulled from the library" });
    } else {
      onProgress({ stage: "memory", detail: "no relevant library refs" });
    }
  }

  onProgress({ stage: "generating", detail: `local Ollama (${OLLAMA.model})` + (refs.length ? ` + ${refs.length} ref(s)` : "") });
  const gen = await generateCandidate(fileContent, instruction, ext, contextBlock);
  onProgress({ stage: "generated", detail: `${gen.code.length} chars in ${gen.gen_ms}ms`, gen_ms: gen.gen_ms });
  onProgress({ stage: "falsifying", detail: `Docker sandbox (.${ext})` });
  const verdict = await falsifyInSandbox(gen.code, ext);
  const v = verdict.ok === true ? "FORGED" : verdict.ok === false ? "INCINERATED" : "INCONCLUSIVE";
  onProgress({ stage: "verdict", detail: v, verdict: v });
  return {
    code: gen.code, model: gen.model, gen_ms: gen.gen_ms,
    forged: verdict.ok === true, // real: compiles/parses clean in the sandbox
    verdict: v,
    compile_ok: verdict.ok,
    compile_log: verdict.log, compile_exit: verdict.exit, sandbox_stage: verdict.stage,
    memory_ref_count: refs.length,
    memory_refs: refs.map((s) => memory.previewOf(s)),
  };
}

module.exports = { ollamaGenerate, generateCandidate, falsifyInSandbox, sandboxProfile, getMemoryRefs, applyWithBackup, restoreBackup, forgeOne, OLLAMA, SANDBOX_IMAGE };

// ---- CLI self-test ----
if (require.main === module) {
  (async () => {
    const [, , file, ...rest] = process.argv;
    const instruction = rest.join(" ") || "add strict TypeScript types and fix any obvious bugs";
    if (!file) { console.error('usage: node codeforge.cjs <file> "<instruction>"'); process.exit(2); }
    const ext = path.extname(file).replace(".", "") || "ts";
    const content = fs.readFileSync(file, "utf8");
    console.log(`[forge] model=${OLLAMA.model} sandbox=${SANDBOX_IMAGE} target=${file}`);
    console.log("[forge] generating candidate…");
    const r = await forgeOne(content, instruction, ext);
    console.log(`[forge] generated in ${r.gen_ms}ms (${r.code.length} chars)`);
    console.log(`[forge] sandbox compile → ${r.verdict} (exit ${r.compile_exit})`);
    if (!r.forged) console.log("[forge] compile log:\n" + r.compile_log);
    else console.log("[forge] candidate (first 400 chars):\n" + r.code.slice(0, 400));
  })().catch((e) => { console.error("[forge] ERROR:", e.message); process.exit(1); });
}
