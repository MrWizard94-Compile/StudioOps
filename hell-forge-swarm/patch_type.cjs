const fs = require('fs');
let code = fs.readFileSync('server.ts', 'utf-8');
code = code.replace(
  '  score: number;\n}',
  '  score: number;\n  diffLines?: number | string;\n}'
);
fs.writeFileSync('server.ts', code);
