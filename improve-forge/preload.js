// Hell Forge Swarm — preload bridge (context-isolated).
// Exposes a minimal, safe API surface to the renderer. No Node access in the page.

const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('forge', {
  status: () => ipcRenderer.invoke('forge:status'),
  doctor: () => ipcRenderer.invoke('forge:doctor'),
  properties: () => ipcRenderer.invoke('forge:properties'),
  elites: () => ipcRenderer.invoke('forge:elites'),
  solutions: () => ipcRenderer.invoke('forge:solutions'),
  ignite: (opts) => ipcRenderer.invoke('forge:ignite', opts),
  system: () => ipcRenderer.invoke('forge:system'),
  files: (opts) => ipcRenderer.invoke('forge:files', opts),
  fileContent: (opts) => ipcRenderer.invoke('forge:filecontent', opts),
  crawl: (opts) => ipcRenderer.invoke('forge:crawl', opts),
  forge: (opts) => ipcRenderer.invoke('forge:forge', opts),
  apply: (opts) => ipcRenderer.invoke('forge:apply', opts),
  restore: (opts) => ipcRenderer.invoke('forge:restore', opts),
  // Subscribe to real forge/crawl milestone events; returns an unsubscribe fn.
  onStage: (cb) => {
    const h = (_e, data) => cb(data);
    ipcRenderer.on('forge:stage', h);
    return () => ipcRenderer.removeListener('forge:stage', h);
  },
});
