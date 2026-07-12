// Hell Forge Swarm — renderer logic. Talks to the local engine via window.forge (preload IPC).
"use strict";

const $ = (id) => document.getElementById(id);
const api = window.forge; // preload exposes window.forge; don't shadow that global name

let opt = { limit: 8, selfOnly: true, top: 20, probe: 8 };
let busy = false;

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

/* ---------- metrics ---------- */
function setMetrics(s) {
  if (!s || !s.ok) return;
  $("m-outcomes").textContent = s.outcomes ?? "—";
  $("m-elites").textContent = s.elites ?? "—";
  $("m-bans").textContent = s.bans ?? "—";
  $("m-kills").textContent = s.kills ?? "—";
  $("m-gen").textContent = s.generation_max ?? "—";
  $("e-catalog").textContent = s.catalog_paths ?? "—";
  $("e-gen").textContent = s.generation_max ?? "—";
  $("e-exp").textContent = s.experiments ?? "—";
}

async function refreshStatus() {
  const s = await api.status();
  if (!s.ok) { log("status: " + (s.error || "unknown"), "err"); return; }
  setMetrics(s);
}

/* ---------- real engine telemetry (no simulated numbers) ---------- */
function setEng(id, state, val) {
  const el = $(id);
  if (!el) return;
  el.classList.remove("ok", "warn", "down");
  el.classList.add(state);
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
    setEng("eng-ollama", ol.up ? (ol.code_model ? "ok" : "warn") : "down",
      ol.up ? ((ol.models ? ol.models.length : 0) + " models") : "down");

    const jn = s.janus || {};
    // Orchestrator up but its memory/cognition containers down = warn, not down.
    const janusState = !jn.up ? "down" : (jn.memory === "ok" ? "ok" : "warn");
    setEng("eng-janus", janusState, jn.up ? (jn.tasks_accepted + "/" + jn.tasks_total + " tasks") : "down");

    const sl = s.smart_library || {};
    setEng("eng-smartlib", sl.up ? "ok" : "down", sl.up ? "ok" : (sl.status || "down"));

    const dr = s.deep_research || {};
    setEng("eng-dre", dr.present ? "ok" : "down",
      dr.present ? ("v" + dr.genome_version + " · " + dr.solutions + " sol") : "absent");

    const sw = s.swarm || {};
    setEng("eng-swarm", sw.outcomes > 0 ? "ok" : "warn", sw.outcomes + " out · " + sw.elites + " elite");

    log(`Engines: docker=${dc.up ? "up" : "down"} ollama=${ol.up ? "up" : "down"} janus=${jn.up ? "up" : "down"}(mem ${jn.memory}) smart-lib=${sl.up ? "up" : "down"} deep-research=v${dr.genome_version}(${dr.solutions} sol)`, "info");
  } catch (e) {
    log("engine probe failed: " + e.message, "err");
  } finally {
    if (btn) btn.classList.remove("spin");
  }
}

async function refreshElites() {
  const r = await api.elites();
  if (!r.ok) { log("elites: " + r.error, "err"); return; }
  $("forged-count").textContent = r.count;
  const box = $("forged");
  if (!r.elites.length) { box.innerHTML = `<div class="empty">No forged artifacts yet.</div>`; return; }
  box.innerHTML = "";
  for (const e of r.elites) {
    const el = document.createElement("div");
    el.className = "artifact";
    el.innerHTML =
      `<div class="art-h"><div><div class="art-id">${escapeHtml(e.id)}</div>` +
      `<div class="art-gene">${escapeHtml(e.target)} · ${escapeHtml(e.lever)} · ${escapeHtml(e.tactic)}</div></div>` +
      `<span class="tierpill">${escapeHtml(e.tier || "elite")}</span></div>` +
      `<div class="art-note">${escapeHtml(e.note || "—")}</div>`;
    box.appendChild(el);
  }
}

/* ---------- candidates ---------- */
function renderCandidates(list) {
  const box = $("candidates");
  $("cand-count").textContent = list.length;
  if (!list.length) { box.innerHTML = `<div class="empty">Wave produced no non-skipped candidates.</div>`; return; }
  box.innerHTML = "";
  for (const c of list) {
    const v = c.verdict;
    const el = document.createElement("div");
    el.className = "cand " + v;
    const label = v === "SUPPORTED" ? "FORGED" : v === "KILLED" ? "INCINERATED" : "INCONCLUSIVE";
    el.innerHTML =
      `<div class="cand-top"><span class="cand-id">${escapeHtml(c.id)}</span>` +
      `<span><span class="vb ${v}">${label}</span><span class="tierpill">${escapeHtml(c.tier || "?")}</span></span></div>` +
      `<div class="cand-meta">${escapeHtml(c.target)} · ${escapeHtml(c.tactic)}</div>` +
      `<div class="cand-note">${escapeHtml(c.note || "")}</div>`;
    box.appendChild(el);
  }
}

/* ---------- pipeline animation ---------- */
const STAGES = ["score", "swarm", "falsify", "learn", "forged"];
let stageTimer = null;
function pipeline(on) {
  $("pipeline").classList.toggle("hidden", !on);
  $("sweep").classList.toggle("on", on);
  $("title").classList.toggle("on", on);
  document.querySelectorAll(".stage").forEach((s) => s.classList.remove("on", "done"));
  if (stageTimer) { clearInterval(stageTimer); stageTimer = null; }
  if (!on) { setBar(0, "idle"); return; }
  let i = 0;
  const mark = () => {
    document.querySelectorAll(".stage").forEach((s, idx) => {
      s.classList.toggle("done", idx < i);
      s.classList.toggle("on", idx === i);
    });
    setBar(Math.min(95, (i / STAGES.length) * 100), STAGES[Math.min(i, STAGES.length - 1)]);
  };
  mark();
  stageTimer = setInterval(() => { if (i < STAGES.length - 1) { i++; mark(); } }, 1400);
}
function setBar(pct, state) {
  $("pl-bar").style.width = pct + "%";
  $("pl-pct").textContent = Math.round(pct) + "%";
  $("pl-state").textContent = state;
}
function pipelineDone() {
  if (stageTimer) { clearInterval(stageTimer); stageTimer = null; }
  document.querySelectorAll(".stage").forEach((s) => { s.classList.remove("on"); s.classList.add("done"); });
  setBar(100, "forged");
  $("sweep").classList.remove("on");
  $("title").classList.remove("on");
}

/* ---------- actions ---------- */
function setBusy(b) {
  busy = b;
  ["btn-ignite", "btn-doctor", "btn-props"].forEach((id) => ($(id).disabled = b));
  $("btn-ignite").textContent = b ? "⟳ Smelting…" : "▶ Ignite Swarm";
}

async function ignite() {
  if (busy) return;
  setBusy(true);
  pipeline(true);
  log(`Igniting swarm — ${opt.limit} candidates, self-only=${opt.selfOnly}. Falsifying locally…`);
  const r = await api.ignite(opt);
  if (!r.ok) { log("ignite: " + r.error, "err"); pipeline(false); setBusy(false); return; }
  pipelineDone();
  log(`Generation ${r.generation} · top score ${r.top_score}`, "ok");
  log(`Verdicts: ${r.supported} SUPPORTED / ${r.killed} KILLED / ${r.inconclusive} INCONCLUSIVE (of ${r.attempted})`, r.killed > 0 ? "warn" : "ok");
  if (r.top) log("Top hypothesis: " + r.top);
  renderCandidates(r.candidates || []);
  setMetrics({ ok: true, outcomes: r.outcomes, bans: r.bans, generation_max: r.generation });
  await refreshStatus();
  await refreshElites();
  await refreshSystem();
  setBusy(false);
}

async function runDoctor() {
  if (busy) return;
  setBusy(true);
  const badge = $("m-reliable");
  badge.className = "badge run"; badge.textContent = "CHECKING…";
  $("e-tests").textContent = "running…"; $("e-tests").className = "amber";
  log("Running reliability gate (real unit suite + property checks)…");
  const r = await api.doctor();
  if (!r.ok) { log("doctor: " + r.error, "err"); badge.className = "badge bad"; badge.textContent = "ERROR"; setBusy(false); return; }
  badge.className = "badge " + (r.reliable ? "ok" : "bad");
  badge.textContent = r.reliable ? "RELIABLE" : "NOT RELIABLE";
  const tests = r.unit_tests_ok === true ? "PASS" : r.unit_tests_ok === false ? "FAIL" : "n/a";
  $("e-tests").textContent = tests; $("e-tests").className = r.unit_tests_ok === false ? "red" : "ember";
  log(`Doctor: ${r.reliable ? "RELIABLE" : "NOT RELIABLE"} · outcomes=${r.outcomes} elites=${r.elites} kills=${r.kills} shipped=${r.shipped} tests=${tests}`, r.reliable ? "ok" : "err");
  (r.issues || []).forEach((i) => log("issue: " + i, "warn"));
  setMetrics({ ok: true, outcomes: r.outcomes, elites: r.elites, bans: r.bans, kills: r.kills });
  setBusy(false);
}

async function runProps() {
  if (busy) return;
  setBusy(true);
  $("e-props").textContent = "probing…"; $("e-props").className = "amber";
  log("Property probe — randomized falsification of core invariants…");
  const r = await api.properties();
  if (!r.ok) { log("properties: " + r.error, "err"); $("e-props").textContent = "error"; $("e-props").className = "red"; setBusy(false); return; }
  $("e-props").textContent = r.all_ok ? `${r.checked}/${r.checked} held` : `${r.failed.length} failed`;
  $("e-props").className = r.all_ok ? "ember" : "red";
  log(`Property probe: ${r.all_ok ? "ALL HELD" : "FALSIFIED"} — ${r.checked} invariants across ${r.total_cases} random cases`, r.all_ok ? "ok" : "err");
  (r.results || []).forEach((p) => log(`  ${p.ok ? "✓" : "✗"} ${p.name} (${p.cases} cases)`, p.ok ? "info" : "err"));
  if (!r.all_ok) r.failed.forEach((f) => log("FALSIFIED: " + f, "err"));
  setBusy(false);
}

/* ---------- wiring ---------- */
function switchTab(which) {
  $("tab-crucible").classList.toggle("active", which === "crucible");
  $("tab-forged").classList.toggle("active", which === "forged");
  $("view-crucible").classList.toggle("hidden", which !== "crucible");
  $("view-forged").classList.toggle("hidden", which !== "forged");
  if (which === "forged") refreshElites();
}

function init() {
  if (!api) {
    log("window.forge unavailable — run this inside the Electron app (npm start), not a browser.", "err");
    return;
  }
  $("btn-ignite").addEventListener("click", ignite);
  $("btn-doctor").addEventListener("click", runDoctor);
  $("btn-props").addEventListener("click", runProps);
  $("tab-crucible").addEventListener("click", () => switchTab("crucible"));
  $("tab-forged").addEventListener("click", () => switchTab("forged"));
  $("opt-selfonly").addEventListener("change", (e) => (opt.selfOnly = e.target.checked));
  $("lim-up").addEventListener("click", () => { opt.limit = Math.min(24, opt.limit + 2); $("opt-limit").textContent = opt.limit; });
  $("lim-dn").addEventListener("click", () => { opt.limit = Math.max(2, opt.limit - 2); $("opt-limit").textContent = opt.limit; });
  $("eng-refresh").addEventListener("click", refreshSystem);

  log("Hell Forge Swarm online. Local engine, no API. Ignite to run a real falsification wave.", "ok");
  refreshStatus();
  refreshElites();
  refreshSystem();
}

window.addEventListener("DOMContentLoaded", init);
