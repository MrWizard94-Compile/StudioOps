// Hell Forge Swarm — Electron main process.
// Local desktop app: drives the WPAI improve-swarm engine through bridge.ps1 (pwsh).
// No web server, no Gemini, no API key. Real falsification only.

const { app, BrowserWindow, ipcMain, shell } = require('electron');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');
const codeforge = require('./forge/codeforge.cjs');

const APP_DIR = __dirname;
const BRIDGE = path.join(APP_DIR, 'bridge.ps1');
const JANUS_ROOT = 'C:\\WPAI\\AI-Research\\Janus';
const JANUS_REGISTRY = path.join(JANUS_ROOT, 'workloads', 'registry.json');

// Resolve a renderer-supplied relative path strictly inside a root (no traversal).
function resolveInRoot(root, rel) {
  const rootFull = path.resolve(root);
  const target = path.resolve(rootFull, rel || '');
  if (target !== rootFull && !target.startsWith(rootFull + path.sep)) return null;
  return target;
}

// If an absolute file path lives under a registered Janus workload, return that workload
// (so applying goes through the Janus validation gate + receipt — never a direct write).
function janusWorkloadFor(absPath) {
  let reg;
  try { reg = JSON.parse(fs.readFileSync(JANUS_REGISTRY, 'utf8')); }
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
      // Invariant: registered workloads may only be mutated by Janus (validation receipt).
      return {
        ok: false,
        blocked: true,
        registered: true,
        workload: wl.id,
        profile: wl.profile,
        error: `"${opts.path}" is registered Janus workload "${wl.id}" (profile ${wl.profile}). ` +
          `Applying must go through the Janus validation gate (janus patch submit --apply), which produces a receipt. ` +
          `Hell Forge will not write into a registered workload directly.`,
      };
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
