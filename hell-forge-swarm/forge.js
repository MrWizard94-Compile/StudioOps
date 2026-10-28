const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');

// Color Palette shifts
code = code.replace(/emerald/g, 'orange');
code = code.replace(/blue/g, 'red');
code = code.replace(/purple/g, 'amber');
code = code.replace(/cyan/g, 'orange');
code = code.replace(/slate/g, 'zinc');
code = code.replace(/rgba\(16,185,129/g, 'rgba(234,88,12'); // orange-600 rgb
code = code.replace(/bg-zinc-900\/50/g, 'bg-zinc-950/80'); // Darker header

// Terminology
code = code.replace(/SWARM-SANDBOX/g, 'HELL-FORGE SWARM');
code = code.replace(/Swarm-Sandbox/g, 'Hell-Forge');
code = code.replace(/Workspace Compiler/g, 'Crucible Compiler');
code = code.replace(/Proven Improvements Archive/g, 'Forged Artifacts Archive');
code = code.replace(/Swarm Sandbox Running/g, 'Hell Forge Smelting...');
code = code.replace(/Start Sandbox Swarm Optimizer/g, 'Ignite Hell Forge Optimizer');
code = code.replace(/Falsifying/g, 'Incinerating');
code = code.replace(/Falsified/g, 'Incinerated');
code = code.replace(/Proven/g, 'Forged');
code = code.replace(/Sandbox Tests/g, 'Crucible Tests');
code = code.replace(/Virtual Falsification Sandbox Logs/g, 'Hell Forge Crucible Logs');
code = code.replace(/Apply & Deploy Proven Code to Live App/g, 'Extract & Deploy Forged Code');
code = code.replace(/Swarm Processing Verdicts/g, 'Furnace Processing Verdicts');
code = code.replace(/Pipeline State:/g, 'Forge State:');
code = code.replace(/Autonomous Double-Falsification Compiler Sandbox/g, 'Autonomous Double-Incineration Compiler Sandbox');
code = code.replace(/Sandbox Env/g, 'Furnace Env');

// Change the main logo icon from Layers to Flame
code = code.replace(/Layers className="h-4 w-4"/g, 'Flame className="h-4 w-4 text-zinc-950 fill-zinc-950"');
if (!code.includes('Flame,')) {
    code = code.replace(/import \{/g, 'import { Flame,');
}

fs.writeFileSync('src/App.tsx', code);

let serverCode = fs.readFileSync('server.ts', 'utf-8');
serverCode = serverCode.replace(/Swarm Sandbox/g, 'Hell Forge');
serverCode = serverCode.replace(/Sandboxed Falsification Engine/g, 'Hell Forge Crucible Engine');
serverCode = serverCode.replace(/Falsifying Agent/g, 'Incinerating Agent');
serverCode = serverCode.replace(/falsification checks/g, 'incineration checks');
serverCode = serverCode.replace(/double-falsification audit/g, 'double-incineration audit');
fs.writeFileSync('server.ts', serverCode);
