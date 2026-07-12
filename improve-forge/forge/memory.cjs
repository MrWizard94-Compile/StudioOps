// Smart-Library read path — the half the crawler was missing. Lets the code-forge and the UI
// actually USE the harvested corpus (query it), instead of write-only seeding.
"use strict";

const SMARTLIB = process.env.HFS_SMARTLIB || "http://127.0.0.1:8000";

async function health(timeoutMs = 4000) {
  try {
    const r = await fetch(SMARTLIB + "/health", { signal: AbortSignal.timeout(timeoutMs) });
    if (!r.ok) return { ok: false, status: "http " + r.status };
    const j = await r.json();
    return { ok: j.status === "ok", status: j.status };
  } catch (e) {
    return { ok: false, status: "unreachable" };
  }
}

// Retrieval-only semantic search (no LLM synthesis) — fast + token-capped. Returns raw slices.
async function queryContext(query, { limit = 5, maxChars = 4000, timeoutMs = 25000 } = {}) {
  const r = await fetch(SMARTLIB + "/query/context", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query: String(query || ""), limit, max_chars: maxChars }),
    signal: AbortSignal.timeout(timeoutMs),
  });
  if (!r.ok) throw new Error("smart-library query HTTP " + r.status);
  const j = await r.json();
  return { slices: Array.isArray(j.slices) ? j.slices : [], total_chars: j.total_chars || 0 };
}

async function seed(content, category = "Crawled Open-Source", language = "All", timeoutMs = 40000) {
  const r = await fetch(SMARTLIB + "/seed", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ content, category, language }),
    signal: AbortSignal.timeout(timeoutMs),
  });
  return r.ok;
}

// A short, UI-friendly preview of a retrieved slice (first meaningful line + provenance if present).
function previewOf(slice) {
  const text = String(slice || "").trim();
  const src = (text.match(/--\s*source:\s*(\S+)/i) || [])[1] || "";
  const first = text.split("\n").map((l) => l.trim()).find((l) => l && !l.startsWith("[") && !l.startsWith("--")) || text.slice(0, 80);
  return { source: src, preview: first.slice(0, 120) };
}

module.exports = { health, queryContext, seed, previewOf, SMARTLIB };
