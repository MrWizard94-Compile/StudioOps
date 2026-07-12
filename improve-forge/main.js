// Hell Forge Swarm — Electron main process.
// Local desktop app: drives the WPAI improve-swarm engine through bridge.ps1 (pwsh).
// No web server, no Gemini, no API key. Real falsification only.

const { app, BrowserWindow, ipcMain, shell } = require('electron');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');
const codeforge = require('./forge/codeforge.cjs');
const { janusWorkloadFor, stageJanusJob } = require('./forge/janusjob.cjs');

const APP_DIR = __dirname;
const BRIDGE = path.join(APP_DIR, 'bridge.ps1');
const DRE_ROOT = 'C:\\WPAI\\AI-Research\\deep_research_engine';
let researchProc = null; // the single in-flight deep_research generation, if any

// Resolve a renderer-supplied relative path strictly inside a root (no traversal).
function resolveInRoot(root, rel) {
  const rootFull = path.resolve(root);
  const target = path.resolve(rootFull, rel || '');
  if (target !== rootFull && !target.startsWith(rootFull + path.sep)) return null;
  return target;
}

// Resolve a PowerShell 7 executable (pwsh); fall back to Windows PowerShell.
function psExe() {
  return process.platform === 'win32' ? 'pwsh' : 'pwsh';
}

// Spawn the JSON bridge for a verb and resolve its parsed output.
function runBridge(verb, opts = {}) {
  return new Promise((resolve) => {
    const args = ['-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', BRIDGE, verb];
    if (opts.limit) args.push('-Limit', String(opts.limit));
    if (opts.top) args.push('-Top', String(opts.top));
    if (opts.probe) args.push('-Probe', String(opts.probe));
    if (opts.selfOnly) args.push('-SelfOnly');
    if (opts.root) args.push('-Root', String(opts.root));
    if (opts.path) args.push('-Path', String(opts.path));
    if (opts.crawlProfile) args.push('-CrawlProfile', String(opts.crawlProfile));
    if (opts.only) args.push('-Only', String(opts.only));

    let ps;
    try {
      ps = spawn(psExe(), args, { cwd: APP_DIR, windowsHide: true });
    } catch (e) {
      resolve({ ok: false, error: 'Failed to launch pwsh: ' + e.message });
      return;
    }

    let out = '';
    let err = '';
    ps.stdout.on('data', (d) => (out += d.toString('utf8')));
    ps.stderr.on('data', (d) => (err += d.toString('utf8')));
    ps.on('error', (e) => resolve({ ok: false, error: 'pwsh not found on PATH: ' + e.message }));
    ps.on('close', (code) => {
      // The bridge prints one compact JSON object; tolerate any leading noise.
      const start = out.indexOf('{');
      const end = out.lastIndexOf('}');
      if (start >= 0 && end > start) {
        try {
          resolve(JSON.parse(out.slice(start, end + 1)));
          return;
        } catch (e) {
          /* fall through */
        }
      }
      resolve({ ok: false, error: (err || out || `bridge exited ${code}`).trim().slice(0, 500) });
    });
  });
}

ipcMain.handle('forge:status', () => runBridge('status'));
ipcMain.handle('forge:doctor', () => runBridge('doctor'));
ipcMain.handle('forge:properties', () => runBridge('properties'));
ipcMain.handle('forge:elites', () => runBridge('elites'));
ipcMain.handle('forge:solutions', () => runBridge('solutions'));
ipcMain.handle('forge:ignite', (_e, opts) => runBridge('ignite', opts || {}));
ipcMain.handle('forge:system', () => runBridge('system'));
ipcMain.handle('forge:files', (_e, opts) => runBridge('files', opts || {}));
ipcMain.handle('forge:filecontent', (_e, opts) => runBridge('filecontent', opts || {}));
ipcMain.handle('forge:crawl', async (_e, opts) => {
  const emit = (s) => { try { _e.sender.send('forge:stage', { op: 'crawl', ...s }); } catch (err) {} };
  emit({ stage: 'crawling', detail: 'GitHub REST API — license allow-list + secret filter' });
  const r = await runBridge('crawl', opts || {});
  if (r && r.ok) emit({ stage: 'seeded', detail: `${r.kept} kept / ${r.seeded} seeded into Smart-Library` });
  emit({ stage: 'done', detail: 'crawl complete' });
  return r;
});

// --- Node-native code-forge pillar (local Ollama generate + Docker falsify + apply) ---

// Generate a candidate with local Ollama and falsify it by real compile/parse in Docker.
ipcMain.handle('forge:forge', async (_e, opts) => {
  opts = opts || {};
  try {
    const root = opts.root || APP_DIR;
    const abs = resolveInRoot(root, opts.path);
    if (!abs) return { ok: false, error: 'path outside workspace' };
    if (!fs.existsSync(abs)) return { ok: false, error: 'file not found: ' + opts.path };
    const content = fs.readFileSync(abs, 'utf8');
    const ext = path.extname(abs).replace('.', '').toLowerCase() || 'ts';
    const instruction = opts.instruction ||
      'Improve clarity and robustness and fix any latent bugs, without changing public behavior or exports.';
    const emit = (s) => { try { _e.sender.send('forge:stage', { op: 'forge', ...s }); } catch (err) {} };
    const r = await codeforge.forgeOne(content, instruction, ext, emit);
    const wl = janusWorkloadFor(abs);
    return { ok: true, path: opts.path, ext, original: content, workload: wl ? wl.id : null, ...r };
  } catch (e) {
    return { ok: false, error: e.message };
  }
});

// Apply a forged candidate. Registered Janus workloads go through the validation gate
// (receipt) and are NEVER written directly; the app's own (unregistered) source is written
// with a .bak backup.
ipcMain.handle('forge:apply', async (_e, opts) => {
  opts = opts || {};
  try {
    const root = opts.root || APP_DIR;
    const abs = resolveInRoot(root, opts.path);
    if (!abs) return { ok: false, error: 'path outside workspace' };
    if (typeof opts.code !== 'string' || !opts.code.length) return { ok: false, error: 'no code to apply' };
    const wl = janusWorkloadFor(abs);
    if (wl) {
      // Invariant + HITL doctrine: registered workloads are never direct-written. Stage a
      // ready Janus job (plan + candidate + commands) for the human to run through the gate.
      return stageJanusJob(wl, abs, opts.code, opts.instruction, APP_DIR);
    }
    const res = codeforge.applyWithBackup(abs, opts.code);
    return { ok: true, method: 'backup-write', registered: false, backup: res.backup };
  } catch (e) {
    return { ok: false, error: e.message };
  }
});

// Restore the most recent .bak backup for a file written by forge:apply.
ipcMain.handle('forge:restore', async (_e, opts) => {
  opts = opts || {};
  try {
    const root = opts.root || APP_DIR;
    const abs = resolveInRoot(root, opts.path);
    if (!abs) return { ok: false, error: 'path outside workspace' };
    const res = codeforge.restoreBackup(abs);
    return res.ok ? { ok: true } : { ok: false, error: res.error };
  } catch (e) {
    return { ok: false, error: e.message };
  }
});

// --- deep_research self-improvement: launch ONE bounded generation, stream logs, stop ---
// Non-blocking: resolves as soon as the process starts; output streams via 'research:log'
// events and 'research:done' on exit. deep_research's own single-instance guard prevents
// concurrent runs corrupting its workspace.
ipcMain.handle('forge:research', (e) => {
  if (researchProc) return { ok: false, error: 'a deep_research generation is already running' };
  const send = (ch, d) => { try { e.sender.send(ch, d); } catch (err) {} };
  let proc;
  try {
    // -u / PYTHONUNBUFFERED so stdout streams line-by-line (piped stdout is block-buffered).
    proc = spawn('python', ['-u', 'main.py'], {
      cwd: DRE_ROOT,
      windowsHide: true,
      env: { ...process.env, META_GENERATIONS: '1', OLLAMA_CODE_MODEL: 'qwen2.5-coder:14b', PYTHONIOENCODING: 'utf-8', PYTHONUNBUFFERED: '1' },
    });
  } catch (err) {
    return { ok: false, error: 'failed to launch python: ' + err.message };
  }
  researchProc = proc;
  let buf = '';
  const onData = (d) => {
    buf += d.toString('utf8');
    let i;
    while ((i = buf.indexOf('\n')) >= 0) {
      const line = buf.slice(0, i).replace(/\r$/, '');
      buf = buf.slice(i + 1);
      if (line.trim()) send('research:log', line);
    }
  };
  proc.stdout.on('data', onData);
  proc.stderr.on('data', onData);
  proc.on('error', (err) => send('research:log', 'ERROR: ' + err.message));
  proc.on('close', (code) => {
    if (buf.trim()) send('research:log', buf.trim());
    researchProc = null;
    send('research:done', { code });
  });
  return { ok: true, started: true, pid: proc.pid };
});

ipcMain.handle('forge:researchStop', () => {
  if (!researchProc) return { ok: true, stopped: false };
  const p = researchProc;
  try { p.kill('SIGTERM'); } catch (e) {}
  setTimeout(() => { try { if (p && !p.killed) p.kill('SIGKILL'); } catch (e) {} }, 3000);
  return { ok: true, stopped: true };
});

function createWindow() {
  const win = new BrowserWindow({
    width: 1320,
    height: 880,
    minWidth: 980,
    minHeight: 640,
    backgroundColor: '#09090b',
    title: 'Hell Forge Swarm',
    autoHideMenuBar: true,
    webPreferences: {
      preload: path.join(APP_DIR, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
    },
  });
  win.setMenuBarVisibility(false);
  // Open any external links in the system browser, not inside the app.
  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });
  // Surface renderer console + load failures to the main process stdout (aids debugging).
  win.webContents.on('console-message', (_e, _level, message) => console.log('[renderer] ' + message));
  win.webContents.on('did-fail-load', (_e, code, desc, url) => console.log('[did-fail-load] ' + code + ' ' + desc + ' ' + url));
  win.webContents.on('preload-error', (_e, p, err) => console.log('[preload-error] ' + p + ' :: ' + err.message));

  win.loadFile(path.join(APP_DIR, 'renderer', 'index.html'));
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});

// Don't orphan a running deep_research generation when the app exits.
app.on('before-quit', () => {
  if (researchProc) { try { researchProc.kill('SIGKILL'); } catch (e) {} }
});
