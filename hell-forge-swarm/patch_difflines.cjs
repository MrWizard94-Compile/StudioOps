const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');

code = code.replace(
  '<p className="text-[9px] text-zinc-500 font-mono">Score index: <span className="text-orange-400">{selectedCandidate.score}</span>/100</p>',
  '<p className="text-[9px] text-zinc-500 font-mono">Score index: <span className="text-orange-400">{selectedCandidate.score}</span>/100 | Diff: <span className="text-orange-500 font-bold">{selectedCandidate.diffLines}</span> lines</p>'
);

fs.writeFileSync('src/App.tsx', code);
