const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');
code = code.replace(
  '<RefreshCw className="h-3.5 w-3.5 animate-spin" /> Hell Forge Smelting......',
  '<RefreshCw className="h-3.5 w-3.5 animate-spin" /> <GlitchText text="HELL FORGE SMELTING..." active={true} />'
);
fs.writeFileSync('src/App.tsx', code);
