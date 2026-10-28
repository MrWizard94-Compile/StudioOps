const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');
code = code.replace(
  '<h1 className="text-xs font-bold tracking-widest text-white uppercase font-display flex items-center gap-2">\n              HELL-FORGE SWARM <span className="text-[10px] bg-orange-500/10 text-orange-400 border border-orange-500/20 px-1.5 py-0.5 rounded font-mono uppercase tracking-wider font-semibold">v2.1</span>\n            </h1>',
  '<h1 className="text-xs font-bold tracking-widest text-white uppercase font-display flex items-center gap-2">\n              <GlitchText text="HELL-FORGE SWARM" active={!!activeJobId} /> <span className="text-[10px] bg-orange-500/10 text-orange-400 border border-orange-500/20 px-1.5 py-0.5 rounded font-mono uppercase tracking-wider font-semibold">v2.1</span>\n            </h1>'
);
fs.writeFileSync('src/App.tsx', code);
