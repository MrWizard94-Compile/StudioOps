// Hell Forge Swarm — preload bridge (context-isolated).
// Exposes a minimal, safe API surface to the renderer. No Node access in the page.

const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('forge', {
  status: () => ipcRenderer.invoke('forge:status'),
  doctor: () => ipcRenderer.invoke('forge:doctor'),
  properties: () => ipcRenderer.invoke('forge:properties'),
  elites: () => ipcRenderer.invoke('forge:elites'),
  ignite: (opts) => ipcRenderer.invoke('forge:ignite', opts),
});
