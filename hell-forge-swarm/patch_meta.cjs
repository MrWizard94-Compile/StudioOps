const fs = require('fs');
let meta = JSON.parse(fs.readFileSync('metadata.json', 'utf-8'));
meta.name = "Hell Forge Swarm";
meta.description = "An autonomous double-incineration compiler sandbox that spawns hellish agent swarms to optimize your React codebase.";
fs.writeFileSync('metadata.json', JSON.stringify(meta, null, 2));
