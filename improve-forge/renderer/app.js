// Hell Forge Swarm — unified cockpit renderer. Talks to the local engines via window.forge
// (preload IPC). Every panel is bound to a real verb; nothing here is simulated.
"use strict";

const $ = (id) => document.getElementById(id);
const api = window.forge; // preload exposes window.forge; don't shadow that global name

const state = {
  root: "",
  files: [],
  selectedFile: null,
  originalContent: "",
  forge: null, // last candidate result { verdict, code, original, compile_log, workload, ... }
  viewMode: "code",
  busy: false,
  forgedLoaded: false,
  researchRunning: false,
};

/* ---------- console ---------- */
function log(msg, level = "info") {
  const box = $("console");
  if (box.querySelector(".dim")) box.innerHTML = "";
  const row = document.createElement("div");
  row.className = "log " + (level === "info" ? "" : level);
  const t = new Date().toLocaleTimeString();
  const prefix = { info: "[INFO]", ok: "[OK]", warn: "[WARN]", err: "[FAIL]" }[level] || "[INFO]";
  row.innerHTML = `<span class="t">[${t}]</span><span>${prefix}</span><span>${escapeHtml(msg)}</span>`;
  box.appendChild(row);
  box.scrollTop = box.scrollHeight;
}
function escapeHtml(s) {
  return String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
}

/* ---------- real engine telemetry ---------- */
function setEng(id, st, val) {
  const el = $(id);
  if (!el) return;
  el.classList.remove("ok", "warn", "down");
  el.classList.add(st);
  el.querySelector(".eng-v").textContent = val;
}
async function refreshSystem() {
  const btn = $("eng-refresh");
  if (btn) btn.classList.add("spin");
  try {
    const s = await api.system();
    if (!s || !s.ok) { log("engine telemetry unavailable: " + ((s && s.error) || "unknown"), "warn"); return; }

    const dc = s.docker || {};
    setEng("eng-docker", dc.up ? "ok" : "down", dc.up ? ("v" + (dc.version || "?")) : "down");
    const ol = s.ollama || {};
    setEng("eng-ollama", ol.up ? (ol.code_model ? "ok" : "warn") : "down", ol.up ? ((ol.models ? ol.models.length : 0) + " models") : "down");
    const jn = s.janus || {};
    setEng("eng-janus", !jn.up ? "down" : (jn.memory === "ok" ? "ok" : "warn"), jn.up ? (jn.tasks_accepted + "/" + jn.tasks_total + " tasks") : "down");
    const sl = s.smart_library || {};
    setEng("eng-smartlib", sl.up ? "ok" : "down", sl.up ? "ok" : (sl.status || "down"));
    const dr = s.deep_research || {};
    setEng("eng-dre", dr.present ? "ok" : "down", dr.present ? ("v" + dr.genome_version + " · " + dr.solutions + " sol") : "absent");
    const sw = s.swarm || {};
    setEng("eng-swarm", sw.outcomes > 0 ? "ok" : "warn", sw.outcomes + " out · " + sw.elites + " elite");

    // Header metrics from the same real probe.
    $("m-outcomes").textContent = sw.outcomes ?? "—";
    $("m-elites").textContent = sw.elites ?? "—";
    $("m-kills").textContent = sw.kills ?? "—";
    $("m-genome").textContent = dr.present ? ("v" + dr.genome_version) : "—";

    log(`Engines: docker=${dc.up ? "up" : "down"} ollama=${ol.up ? "up" : "down"} janus=${jn.up ? "up" : "down"}(mem ${jn.memory}) smart-lib=${sl.up ? "up" : "down"} deep-research=v${dr.genome_version}`, "info");
  } catch (e) {
    log("engine probe failed: " + e.message, "err");
  } finally {
    if (btn) btn.classList.remove("spin");
  }
}

/* ---------- pipeline (driven by real onStage events) ---------- */
const STAGES = ["scan", "crawl", "swarm", "falsify", "refine", "forged"];
function setBar(pct, stateLabel) {
  $("pl-bar").style.width = pct + "%";
  $("pl-pct").textContent = Math.round(pct) + "%";
  $("pl-state").textContent = stateLabel;
}
function resetPipeline() {
  document.querySelectorAll(".stage").forEach((s) => s.classList.remove("on", "done"));
  setBar(0, "idle");
}
function advanceTo(key, done) {
  const idx = STAGES.indexOf(key);
  document.querySelectorAll(".stage").forEach((s) => {
    const i = STAGES.indexOf(s.dataset.k);
    s.classList.toggle("done", i < idx || (i === idx && !!done));
    s.classList.toggle("on", i === idx && !done);
  });
  setBar(Math.round(((idx + (done ? 1 : 0.5)) / STAGES.length) * 100), key);
}
function pipelineActive(on) {
  $("sweep").classList.toggle("on", on);
  $("title").classList.toggle("on", on);
}
function pipelineDone() {
  document.querySelectorAll(".stage").forEach((s) => { s.classList.remove("on"); s.classList.add("done"); });
  setBar(100, "forged");
  pipelineActive(false);
}

function handleStage(d) {
  if (!d || !d.stage) return;
  if (d.op === "forge") {
    if (d.stage === "generating") { advanceTo("swarm"); log("Generating candidate — " + d.detail); }
    else if (d.stage === "generated") { log("Candidate generated — " + d.detail, "ok"); }
    else if (d.stage === "falsifying") { advanceTo("falsify"); log("Falsifying in Docker sandbox — " + d.detail); }
    else if (d.stage === "verdict") {
      advanceTo("forged", true);
      log("Sandbox verdict: " + d.verdict, d.verdict === "FORGED" ? "ok" : d.verdict === "INCINERATED" ? "err" : "warn");
    }
  } else if (d.op === "crawl") {
    if (d.stage === "crawling") { advanceTo("crawl"); log("Crawling GitHub — " + d.detail); }
    else if (d.stage === "seeded") { advanceTo("refine", true); log("Seeded Smart-Library — " + d.detail, "ok"); }
    else if (d.stage === "done") { log("Crawl complete."); }
  }
}

/* ---------- busy / controls ---------- */
function setBusy(b, label) {
  state.busy = b;
  ["btn-forge", "btn-crawl", "btn-ignite", "btn-doctor", "btn-props", "btn-apply", "btn-restore"].forEach((id) => {
    const el = $(id);
    if (el) el.disabled = b || (id === "btn-forge" && !state.selectedFile) || (id === "btn-apply" && !state.forge);
  });
  const f = $("btn-forge");
  if (f) f.textContent = b && label === "forge" ? "⟳ Smelting…" : "▶ Ignite File";
}

/* ---------- workspace explorer ---------- */
async function loadFiles() {
  const r = await api.files({});
  if (!r || !r.ok) { log("files: " + ((r && r.error) || "unknown"), "err"); return; }
  state.root = r.root;
  state.files = r.files || [];
  $("ws-root").textContent = "· " + r.count + " files";
  const box = $("filelist");
  if (!state.files.length) { box.innerHTML = `<div class="empty">No source files.</div>`; return; }
  box.innerHTML = "";
  for (const f of state.files) {
    const b = document.createElement("button");
    b.className = "fitem";
    b.dataset.path = f;
    b.innerHTML = `<span class="fi">◆</span><span>${escapeHtml(f)}</span>`;
    b.addEventListener("click", () => selectFile(f));
    box.appendChild(b);
  }
}
async function selectFile(path) {
  if (state.busy) return;
  state.selectedFile = path;
  document.querySelectorAll(".fitem").forEach((el) => el.classList.toggle("active", el.dataset.path === path));
  const r = await api.fileContent({ path });
  if (!r || !r.ok) { log("read " + path + ": " + ((r && r.error) || "unknown"), "err"); return; }
  state.originalContent = r.content;
  state.forge = null;
  showFileReader(r.content, path);
  $("btn-forge").disabled = state.busy;
  $("btn-restore").disabled = state.busy;
  log(`Loaded ${path} (${r.bytes} bytes)`);
}

/* ---------- inspector ---------- */
function showFileReader(content, path) {
  $("insp-title").textContent = "◱ Live File Reader: " + (path || "");
  $("insp-views").classList.add("hidden");
  $("insp-meta").classList.add("hidden");
  $("apply-row").classList.add("hidden");
  const lines = content.split("\n");
  const rows = lines.map((ln, i) => `<div class="fl"><span class="ln">${i + 1}</span><pre>${escapeHtml(ln)}</pre></div>`).join("");
  $("insp-body").innerHTML = `<div class="filereader">${rows}</div>`;
}

function renderCandidate(r) {
  state.forge = r;
  state.viewMode = "code";
  $("insp-title").textContent = "◱ Candidate: " + r.path;
  $("insp-views").classList.remove("hidden");
  setViewTab("code");
  const wlNote = r.workload
    ? `<span class="red">registered workload "${escapeHtml(r.workload)}" — apply routes to Janus receipt gate</span>`
    : `unregistered target — apply writes with a .bak backup`;
  $("insp-meta").classList.remove("hidden");
  $("insp-meta").innerHTML =
    `<span class="vb ${r.verdict}">${r.verdict}</span> · model ${escapeHtml(r.model || "")} · ` +
    `generated ${r.gen_ms}ms · sandbox ${escapeHtml(r.sandbox_stage || "")} (exit ${r.compile_exit}) · ${wlNote}`;
  renderInspectorBody();
  $("apply-row").classList.remove("hidden");
  const applyBtn = $("btn-apply");
  applyBtn.disabled = state.busy;
  applyBtn.textContent = r.workload ? "✓ Apply via Janus" : "✓ Apply & Backup";
  $("apply-msg").textContent = "";
  $("apply-msg").className = "apply-msg";
}
function setViewTab(mode) {
  state.viewMode = mode;
  $("v-code").classList.toggle("active", mode === "code");
  $("v-diff").classList.toggle("active", mode === "diff");
  $("v-tests").classList.toggle("active", mode === "tests");
  renderInspectorBody();
}
function renderInspectorBody() {
  const r = state.forge;
  if (!r) return;
  const body = $("insp-body");
  if (state.viewMode === "code") {
    body.innerHTML = `<pre class="codeview">${escapeHtml(r.code)}</pre>`;
  } else if (state.viewMode === "diff") {
    body.innerHTML = renderDiff(r.original || "", r.code || "");
  } else {
    body.innerHTML = `<pre class="codeview">${escapeHtml(r.compile_log || "(no log)")}</pre>`;
  }
}
function renderDiff(original, modified) {
  const a = original.split("\n"), b = modified.split("\n");
  const max = Math.max(a.length, b.length);
  let rows = "";
  for (let i = 0; i < max; i++) {
    const l = a[i] === undefined ? "" : a[i];
    const rr = b[i] === undefined ? "" : b[i];
    const diff = l !== rr;
    rows += `<div class="drow ${diff ? "diff-yes" : ""}">` +
      `<div class="dcell l"><span class="n">${i + 1}</span><span>${escapeHtml(l)}</span></div>` +
      `<div class="dcell r"><span class="n">${i + 1}</span><span>${escapeHtml(rr)}</span></div></div>`;
  }
  return `<div class="diff">${rows}</div>`;
}

/* ---------- actions ---------- */
async function igniteFile() {
  if (state.busy || !state.selectedFile) return;
  setBusy(true, "forge");
  resetPipeline();
  advanceTo("scan", true);
  pipelineActive(true);
  const instruction = $("instruction").value.trim();
  log(`Igniting ${state.selectedFile} — local Ollama generate → Docker falsify…`);
  const r = await api.forge({ path: state.selectedFile, instruction: instruction || undefined });
  pipelineActive(false);
  if (!r || !r.ok) { log("forge: " + ((r && r.error) || "unknown"), "err"); pipelineDone(); setBusy(false); return; }
  pipelineDone();
  renderCandidate(r);
  await refreshSystem();
  setBusy(false);
}

async function runCrawl() {
  if (state.busy) return;
  setBusy(true, "crawl");
  resetPipeline();
  advanceTo("scan", true);
  pipelineActive(true);
  $("btn-crawl").disabled = true;
  log("Crawling open-source code (license/secret filtered) → Smart-Library…");
  const r = await api.crawl({ limit: 6 });
  pipelineActive(false);
  if (!r || !r.ok) { log("crawl: " + ((r && r.error) || "unknown"), "err"); pipelineDone(); setBusy(false); return; }
  pipelineDone();
  renderCrawled(r);
  log(`Crawl: ${r.harvested} harvested · ${r.kept} kept · ${r.seeded} seeded · memory ${r.memory_up ? "up" : "down"}`, r.seeded > 0 ? "ok" : "warn");
  await refreshSystem();
  setBusy(false);
}
function renderCrawled(r) {
  const box = $("crawled");
  const bits = r.bits || [];
  if (!bits.length) { box.innerHTML = `<div class="empty">No kept snippets this run.</div>`; return; }
  box.innerHTML = "";
  for (const b of bits) {
    const el = document.createElement("div");
    el.className = "bit";
    el.innerHTML =
      `<div class="bit-h"><span class="bit-t">${escapeHtml(b.title)}</span><span class="bit-lic">${escapeHtml(b.license || "?")}</span></div>` +
      `<div class="bit-s">${escapeHtml(b.snippet || "")}</div>`;
    box.appendChild(el);
  }
}

async function applyCandidate() {
  if (state.busy || !state.forge) return;
  setBusy(true);
  const msg = $("apply-msg");
  msg.textContent = "applying…"; msg.className = "apply-msg";
  const r = await api.apply({ path: state.forge.path, code: state.forge.code, instruction: $("instruction").value.trim() || undefined });
  if (r && r.staged) {
    msg.textContent = r.note; msg.className = "apply-msg warn";
    log(`Staged Janus job for ${r.workload} (${r.profile}) → ${r.jobDir}`, "warn");
  } else if (r && r.ok) {
    msg.textContent = `Applied — backup saved as ${r.backup}.`; msg.className = "apply-msg ok";
    log(`Applied ${state.forge.path} (method ${r.method}, backup ${r.backup})`, "ok");
    state.originalContent = state.forge.code;
  } else if (r && r.blocked) {
    msg.textContent = r.error; msg.className = "apply-msg warn";
    log(`Apply gated: ${r.error}`, "warn");
  } else {
    msg.textContent = (r && r.error) || "apply failed"; msg.className = "apply-msg err";
    log("apply: " + ((r && r.error) || "unknown"), "err");
  }
  setBusy(false);
}

async function restoreFile() {
  if (state.busy || !state.selectedFile) return;
  setBusy(true);
  const r = await api.restore({ path: state.selectedFile });
  if (r && r.ok) {
    log(`Restored ${state.selectedFile} from backup.`, "ok");
    await selectFile(state.selectedFile);
  } else {
    log("restore: " + ((r && r.error) || "no backup"), "warn");
  }
  setBusy(false);
}

/* ---------- swarm (auto-experiments + reliability) ---------- */
async function igniteSwarm() {
  if (state.busy) return;
  setBusy(true);
  resetPipeline(); advanceTo("swarm"); pipelineActive(true);
  log("Igniting swarm wave — self-injected recipes, score, real auto-experiments…");
  const r = await api.ignite({ limit: 8, selfOnly: true });
  pipelineActive(false);
  if (!r || !r.ok) { log("ignite: " + ((r && r.error) || "unknown"), "err"); pipelineDone(); setBusy(false); return; }
  advanceTo("forged", true); pipelineDone();
  log(`Gen ${r.generation} · ${r.supported} SUPPORTED / ${r.killed} KILLED / ${r.inconclusive} INCONCLUSIVE of ${r.attempted}`, r.killed > 0 ? "warn" : "ok");
  if (r.top) log("Top hypothesis: " + r.top);
  await refreshSystem();
  setBusy(false);
}
async function runDoctor() {
  if (state.busy) return;
  setBusy(true);
  const badge = $("m-reliable"); badge.className = "badge run"; badge.textContent = "CHECKING…";
  log("Running reliability gate (real unit suite + property checks)…");
  const r = await api.doctor();
  if (!r || !r.ok) { log("doctor: " + ((r && r.error) || "unknown"), "err"); badge.className = "badge bad"; badge.textContent = "ERROR"; setBusy(false); return; }
  badge.className = "badge " + (r.reliable ? "ok" : "bad");
  badge.textContent = r.reliable ? "RELIABLE" : "NOT RELIABLE";
  const tests = r.unit_tests_ok === true ? "PASS" : r.unit_tests_ok === false ? "FAIL" : "n/a";
  log(`Doctor: ${r.reliable ? "RELIABLE" : "NOT RELIABLE"} · outcomes=${r.outcomes} elites=${r.elites} kills=${r.kills} tests=${tests}`, r.reliable ? "ok" : "err");
  (r.issues || []).forEach((i) => log("issue: " + i, "warn"));
  setBusy(false);
}
async function runProps() {
  if (state.busy) return;
  setBusy(true);
  log("Property probe — randomized falsification of core invariants…");
  const r = await api.properties();
  if (!r || !r.ok) { log("properties: " + ((r && r.error) || "unknown"), "err"); setBusy(false); return; }
  log(`Property probe: ${r.all_ok ? "ALL HELD" : "FALSIFIED"} — ${r.checked} invariants across ${r.total_cases} random cases`, r.all_ok ? "ok" : "err");
  (r.results || []).forEach((p) => log(`  ${p.ok ? "✓" : "✗"} ${p.name} (${p.cases} cases)`, p.ok ? "info" : "err"));
  (r.failed || []).forEach((f) => log("FALSIFIED: " + f, "err"));
  setBusy(false);
}

/* ---------- deep_research generation (bounded, streamed) ---------- */
async function launchResearch() {
  if (state.researchRunning) {
    await api.researchStop();
    log("Stopping deep_research generation…", "warn");
    return;
  }
  const r = await api.research();
  if (!r || !r.ok) { log("deep_research: " + ((r && r.error) || "unknown"), "err"); return; }
  state.researchRunning = true;
  $("btn-research").textContent = "■ Stop deep_research Generation";
  resetPipeline(); advanceTo("swarm"); pipelineActive(true);
  log(`deep_research generation launched (pid ${r.pid}) — 1 bounded generation, genome evolves. Streaming…`, "ok");
}

/* ---------- forged artifacts ---------- */
async function loadForged() {
  const el = await api.elites();
  const box = $("forged");
  if (el && el.ok) {
    $("forged-count").textContent = el.count;
    if (!el.elites.length) box.innerHTML = `<div class="empty">No forged elites yet.</div>`;
    else {
      box.innerHTML = "";
      for (const e of el.elites) {
        const d = document.createElement("div");
        d.className = "artifact";
        d.innerHTML =
          `<div class="art-h"><div><div class="art-id">${escapeHtml(e.id)}</div>` +
          `<div class="art-gene">${escapeHtml(e.target)} · ${escapeHtml(e.lever)} · ${escapeHtml(e.tactic)}</div></div>` +
          `<span class="tierpill">${escapeHtml(e.tier || "elite")}</span></div>` +
          `<div class="art-note">${escapeHtml(e.note || "—")}</div>`;
        box.appendChild(d);
      }
    }
  } else { box.innerHTML = `<div class="empty">elites: ${(el && el.error) || "unavailable"}</div>`; }

  const sol = await api.solutions();
  const sbox = $("solutions");
  if (sol && sol.ok) {
    $("genome-badge").textContent = `· v${sol.genome_version} · ${sol.generations} gens · ${sol.count} banked`;
    if (!sol.solutions.length) sbox.innerHTML = `<div class="empty">No banked solutions yet.</div>`;
    else {
      sbox.innerHTML = "";
      for (const s of sol.solutions) {
        const d = document.createElement("div");
        d.className = "artifact";
        d.innerHTML =
          `<div class="art-h"><div class="art-id">gen ${s.generation}</div><span class="tierpill">solved</span></div>` +
          `<div class="art-note">${escapeHtml(s.objective || "")}</div>` +
          `<div class="art-gene">${escapeHtml(s.timestamp || "")}</div>`;
        sbox.appendChild(d);
      }
    }
  } else { sbox.innerHTML = `<div class="empty">solutions: ${(sol && sol.error) || "unavailable"}</div>`; }
  state.forgedLoaded = true;
}

/* ---------- tabs + init ---------- */
function switchTab(which) {
  $("tab-crucible").classList.toggle("active", which === "crucible");
  $("tab-forged").classList.toggle("active", which === "forged");
  $("view-crucible").classList.toggle("hidden", which !== "crucible");
  $("view-forged").classList.toggle("hidden", which !== "forged");
  if (which === "forged") loadForged();
}

function init() {
  if (!api) {
    log("window.forge unavailable — run inside the Electron app (npm start), not a browser.", "err");
    return;
  }
  $("btn-forge").addEventListener("click", igniteFile);
  $("btn-crawl").addEventListener("click", runCrawl);
  $("btn-apply").addEventListener("click", applyCandidate);
  $("btn-restore").addEventListener("click", restoreFile);
  $("btn-ignite").addEventListener("click", igniteSwarm);
  $("btn-doctor").addEventListener("click", runDoctor);
  $("btn-props").addEventListener("click", runProps);
  $("btn-research").addEventListener("click", launchResearch);
  $("eng-refresh").addEventListener("click", refreshSystem);
  $("tab-crucible").addEventListener("click", () => switchTab("crucible"));
  $("tab-forged").addEventListener("click", () => switchTab("forged"));
  $("v-code").addEventListener("click", () => setViewTab("code"));
  $("v-diff").addEventListener("click", () => setViewTab("diff"));
  $("v-tests").addEventListener("click", () => setViewTab("tests"));

  api.onStage(handleStage); // real forge/crawl milestone events drive the pipeline

  // deep_research generation streams its real stdout here; refresh artifacts when it ends.
  api.onResearchLog((line) => log("[dre] " + line));
  api.onResearchDone((d) => {
    state.researchRunning = false;
    $("btn-research").textContent = "🧬 Run deep_research Generation";
    advanceTo("forged", true); pipelineDone();
    log(`deep_research generation finished (exit ${d.code}).`, d.code === 0 ? "ok" : "warn");
    refreshSystem();
    if (!$("view-forged").classList.contains("hidden")) loadForged();
  });

  log("Hell Forge online. Unified local engine — crawler · swarm · code-forge. No API.", "ok");
  loadFiles();
  refreshSystem();
}

window.addEventListener("DOMContentLoaded", init);
