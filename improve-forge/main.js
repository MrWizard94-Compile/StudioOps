// Hell Forge Swarm — Electron main process.
// Local desktop app: drives the WPAI improve-swarm engine through bridge.ps1 (pwsh).
// No web server, no Gemini, no API key. Real falsification only.

const { app, BrowserWindow, ipcMain, shell } = require('electron');
const path = require('path');
const { spawn } = require('child_process');

const APP_DIR = __dirname;
const BRIDGE = path.join(APP_DIR, 'bridge.ps1');

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
ipcMain.handle('forge:ignite', (_e, opts) => runBridge('ignite', opts || {}));

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
  win.loadFile(path.join(APP_DIR, 'renderer', 'index.html'));
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
