const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');

code = code.replace(
  'className="w-full bg-orange-600 hover:bg-orange-500 text-zinc-950 hover:text-zinc-950 font-bold uppercase tracking-wider text-xs py-3 px-4 rounded transition-all duration-150 shadow-[0_0_15px_rgba(234,88,12,0.2)] hover:shadow-[0_0_20px_rgba(234,88,12,0.4)] disabled:bg-zinc-800 disabled:text-zinc-500 disabled:shadow-none cursor-pointer"',
  'className={`w-full font-bold uppercase tracking-wider text-xs py-3 px-4 rounded transition-all duration-150 cursor-pointer ${activeJobId ? "bg-gradient-to-r from-red-900 to-orange-900 text-orange-400 animate-pulse border border-orange-500/50 shadow-[0_0_30px_rgba(234,88,12,0.5)]" : "bg-orange-600 hover:bg-orange-500 text-zinc-950 shadow-[0_0_15px_rgba(234,88,12,0.2)] hover:shadow-[0_0_20px_rgba(234,88,12,0.4)]"}`}'
);
fs.writeFileSync('src/App.tsx', code);
