#!/usr/bin/env node
// Hell Forge Swarm — headless self-check. The "operate it from the inside" harness.
//
// Exercises every REAL code path the cockpit uses and asserts real behavior — not just
// "did it return something". The point is to prove function, not display, per SOUL.md §3.
// Notably it feeds the Docker falsifier KNOWN-BROKEN code and REQUIRES an INCINERATED verdict,
// so a rubber-stamp would fail the suite.
//
//   node forge/selfcheck.cjs                 # everything (incl. slow Ollama/Docker/crawl)
//   node forge/selfcheck.cjs --fast          # skip the slow ones (forge generation + crawl)
//   node forge/selfcheck.cjs --only=forge     # run one section
//   node forge/selfcheck.cjs --skip=crawl     # run all but these sections
//
// Exit code = number of failed checks (0 = all green).

"use strict";
const { spawnSync } = require("child_process");
const path = require("path");
const os = require("os");
const fs = require("fs");
const codeforge = require("./codeforge.cjs");
const janusjob = require("./janusjob.cjs");

const APP_DIR = path.resolve(__dirname, "..");
const BRIDGE = path.join(APP_DIR, "bridge.ps1");
const OLLAMA = "http://127.0.0.1:11434";
const SMARTLIB = "http://127.0.0.1:8000";

// ---- arg parsing ----
const argv = process.argv.slice(2);
const opt = { fast: argv.includes("--fast"), only: null, skip: [] };
for (const a of argv) {
  if (a.startsWith("--only=")) opt.only = a.slice(7).split(",").map((s) => s.trim());
  if (a.startsWith("--skip=")) opt.skip = a.slice(7).split(",").map((s) => s.trim());
}
if (opt.fast) opt.skip.push("forge-generate", "crawl");
const sectionEnabled = (s) => (!opt.only || opt.only.includes(s)) && !opt.skip.includes(s);

// ---- tiny test framework ----
const C = { g: "\x1b[32m", r: "\x1b[31m", y: "\x1b[33m", d: "\x1b[90m", b: "\x1b[1m", x: "\x1b[0m" };
const results = [];
let curSection = "";
function section(name) { curSection = name; if (sectionEnabled(name)) console.log(`\n${C.b}== ${name} ==${C.x}`); }
async function check(name, fn) {
  if (!sectionEnabled(curSection)) return;
  const t0 = Date.now();
  let ok = false, detail = "", err = null;
  try {
    const r = await fn();
    ok = !!(r && r.ok);
    detail = (r && r.detail) || "";
  } catch (e) {
    ok = false; err = e; detail = e.message;
  }
  const ms = Date.now() - t0;
  results.push({ section: curSection, name, ok, detail, ms });
  const tag = ok ? `${C.g}PASS${C.x}` : `${C.r}FAIL${C.x}`;
  console.log(`  [${tag}] ${name}  ${C.d}${detail}${detail ? " · " : ""}${ms}ms${C.x}`);
  if (err && !ok) console.log(`         ${C.r}${(err.stack || "").split("\n").slice(0, 2).join(" ")}${C.x}`);
}

// ---- helpers ----
function bridge(verb, extra = []) {
  const args = ["-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", BRIDGE, verb, ...extra];
  const r = spawnSync("pwsh", args, { cwd: APP_DIR, encoding: "utf8", maxBuffer: 32 * 1024 * 1024, timeout: 240000 });
  const out = r.stdout || "";
  const s = out.indexOf("{"), e = out.lastIndexOf("}");
  if (s >= 0 && e > s) {
    try { return JSON.parse(out.slice(s, e + 1)); } catch (err) { /* fall through */ }
  }
  throw new Error("bridge " + verb + " → no JSON (" + ((r.stderr || out) || "").trim().slice(-160) + ")");
}
async function http(method, url, body) {
  const res = await fetch(url, {
    method,
    headers: body ? { "Content-Type": "application/json" } : undefined,
    body: body ? JSON.stringify(body) : undefined,
    signal: AbortSignal.timeout(90000),
  });
  const text = await res.text();
  let json = null; try { json = JSON.parse(text); } catch (e) { /* not json */ }
  return { status: res.status, ok: res.ok, json, text };
}

// ============================ CHECKS ============================
async function run() {
  console.log(`${C.b}Hell Forge Swarm — self-check${C.x}  ${C.d}${new Date().toISOString()}${opt.fast ? " (--fast)" : ""}${C.x}`);

  // ---- runtime ----
  section("runtime");
  await check("docker daemon reachable", () => {
    const r = spawnSync("docker", ["version", "--format", "{{.Server.Version}}"], { encoding: "utf8", timeout: 15000 });
    const v = (r.stdout || "").trim();
    return { ok: !!v, detail: v ? "v" + v : "no server" };
  });
  await check("ollama up + a model present", async () => {
    const r = await http("GET", OLLAMA + "/api/tags");
    const models = (r.json && r.json.models || []).map((m) => m.name);
    return { ok: r.ok && models.length > 0, detail: models.length + " models" };
  });

  // ---- bridge verbs ----
  section("bridge");
  await check("system telemetry: all engines reported", () => {
    const s = bridge("system");
    const keys = ["docker", "ollama", "janus", "smart_library", "deep_research", "swarm"];
    const missing = keys.filter((k) => !(k in s));
    return { ok: s.ok && missing.length === 0, detail: missing.length ? "missing " + missing.join(",") : keys.length + " engines" };
  });
  await check("files: lists real source, incl. bridge.ps1", () => {
    const r = bridge("files");
    return { ok: r.ok && r.count > 0 && r.files.includes("bridge.ps1"), detail: r.count + " files" };
  });
  await check("filecontent: reads a real file", () => {
    const r = bridge("filecontent", ["-Path", "package.json"]);
    return { ok: r.ok && r.bytes > 0 && r.content.includes("improve-forge"), detail: r.bytes + " bytes" };
  });
  await check("filecontent: BLOCKS path traversal (SOUL §9)", () => {
    const r = bridge("filecontent", ["-Path", "..\\..\\..\\..\\Windows\\System32\\drivers\\etc\\hosts"]);
    return { ok: r.ok === false && /outside/.test(r.error || ""), detail: "blocked: " + (r.error || "") };
  });
  await check("properties: invariants hold under random cases", () => {
    const r = bridge("properties");
    return { ok: r.ok && r.all_ok === true && r.checked >= 4, detail: r.checked + " invariants / " + r.total_cases + " cases" };
  });
  await check("elites: well-formed", () => {
    const r = bridge("elites");
    return { ok: r.ok && Array.isArray(r.elites) && typeof r.count === "number", detail: r.count + " elites" };
  });
  await check("solutions: well-formed", () => {
    const r = bridge("solutions");
    return { ok: r.ok && Array.isArray(r.solutions), detail: "genome v" + r.genome_version + " · " + r.count + " solutions" };
  });

  // ---- janus workload boundary ----
  section("janus");
  await check("workload detection: registered mod → gated", () => {
    const wl = janusjob.janusWorkloadFor("C:\\WPAI\\Minecraft\\Mods-1.20.1-Forge\\Node Core\\src\\Main.java");
    return { ok: wl && wl.id === "nodecore", detail: wl ? wl.id + " [" + wl.profile + "]" : "not detected" };
  });
  await check("workload detection: app's own file → unregistered", () => {
    const wl = janusjob.janusWorkloadFor(path.join(APP_DIR, "main.js"));
    return { ok: wl === null, detail: wl ? "WRONGLY matched " + wl.id : "unregistered (safe backup)" };
  });

  // ---- the falsifier must DISCRIMINATE (this is the anti-theater check) ----
  section("falsify");
  await check("known-GOOD code → FORGED (compiles)", async () => {
    const r = await codeforge.falsifyInSandbox("module.exports = (a, b) => a + b;\n", "js");
    return { ok: r.ok === true, detail: "verdict ok=" + r.ok + " exit=" + r.exit };
  });
  await check("known-BROKEN code → INCINERATED (real reject)", async () => {
    const r = await codeforge.falsifyInSandbox("module.exports = (a, b) => { return a + ;\n", "js");
    return { ok: r.ok === false, detail: r.ok === false ? "rejected: " + (r.log || "").split("\n")[0].slice(0, 60) : "RUBBER-STAMPED a syntax error!" };
  });
  await check("unsupported language → INCONCLUSIVE (never fake-pass)", async () => {
    const r = await codeforge.falsifyInSandbox("SELECT 1;", "sql");
    return { ok: r.ok === null, detail: "verdict ok=" + r.ok + " (" + r.stage + ")" };
  });

  // ---- smart-library seed → query round-trip (proves the memory loop) ----
  section("memory");
  const marker = "selfcheck-" + Date.now();
  await check("smart-library /health ok", async () => {
    const r = await http("GET", SMARTLIB + "/health");
    return { ok: r.ok && r.json && r.json.status === "ok", detail: r.json ? r.json.status : "unreachable" };
  });
  await check("seed → query round-trip (real read-back)", async () => {
    const content = `Distinctive self-check pattern ${marker}: use a token bucket with monotonic clock for rate limiting.`;
    const seed = await http("POST", SMARTLIB + "/seed", { content, category: "SelfCheck", language: "Python" });
    if (!seed.ok) return { ok: false, detail: "seed failed HTTP " + seed.status };
    // retrieval-only endpoint (fast, no LLM synthesis)
    const q = await http("POST", SMARTLIB + "/query/context", { query: "token bucket rate limiting " + marker, limit: 5, max_chars: 4000 });
    const slices = (q.json && q.json.slices) || [];
    const found = slices.some((s) => s.includes(marker));
    return { ok: q.ok && found, detail: found ? "retrieved the seeded marker" : slices.length + " slices, marker not found" };
  });
  await check("code-forge getMemoryRefs pulls relevant crawled code", async () => {
    const m = "refcheck-" + Date.now();
    await http("POST", SMARTLIB + "/seed", { content: `Pattern ${m}: sliding-window rate limiter with a deque.`, category: "SelfCheck", language: "Python" });
    const refs = await codeforge.getMemoryRefs(`sliding window rate limiter ${m}`, "py", 3);
    const found = refs.some((s) => s.includes(m));
    return { ok: refs.length > 0 && found, detail: refs.length + " refs · marker " + (found ? "found" : "MISSING") };
  });

  // ---- code-forge full generate → falsify (slow: real Ollama + Docker) ----
  section("forge-generate");
  await check("forge USES the crawled library (full real loop)", async () => {
    const m = "forgemem-" + Date.now();
    await http("POST", SMARTLIB + "/seed", { content: `Reference ${m}: wrap the call in exponential backoff with full jitter and a max-retries cap.`, category: "SelfCheck", language: "JavaScript" });
    const src = "function callApi() {\n  return fetch('/x');\n}\nmodule.exports = { callApi };\n";
    const r = await codeforge.forgeOne(src, `add exponential backoff retry (${m}) around the fetch`, "js");
    const valid = ["FORGED", "INCINERATED", "INCONCLUSIVE"].includes(r.verdict) && typeof r.compile_log === "string" && r.code.length > 0;
    return { ok: valid && r.memory_ref_count >= 1, detail: r.verdict + " · used " + r.memory_ref_count + " lib refs · gen " + r.gen_ms + "ms" };
  });

  // ---- crawler ----
  section("crawl");
  await check("custom-query crawl: real bits + new-this-run tracking", () => {
    const r = bridge("crawl", ["-Limit", "4", "-Query", "leaky bucket rate limiter"]);
    const bits = r.bits || [];
    const wellFormed = bits.length > 0 && bits.every((b) => b.repo && b.url && b.license !== undefined && typeof b.is_new === "boolean");
    const hasMeta = typeof r.new_this_run === "number" && typeof r.mode === "string";
    return { ok: r.ok && wellFormed && hasMeta, detail: `${r.mode} · harvested ${r.harvested} · new ${r.new_this_run} · seeded ${r.seeded} · ${bits.length} bits` };
  });

  // ---- summary ----
  const failed = results.filter((r) => !r.ok);
  console.log(`\n${C.b}── summary ──${C.x}`);
  console.log(`  ${results.length - failed.length}/${results.length} passed` + (failed.length ? `  ${C.r}(${failed.length} FAILED)${C.x}` : `  ${C.g}ALL GREEN${C.x}`));
  for (const f of failed) console.log(`  ${C.r}✗ ${f.section}/${f.name}${C.x} — ${f.detail}`);
  process.exit(failed.length);
}

run().catch((e) => { console.error("self-check crashed:", e); process.exit(99); });
