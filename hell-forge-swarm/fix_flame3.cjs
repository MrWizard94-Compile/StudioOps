const fs = require('fs');
let lines = fs.readFileSync('src/App.tsx', 'utf-8').split('\n');
lines[1] = lines[1].replace('import { Flame,', 'import {');
fs.writeFileSync('src/App.tsx', lines.join('\n'));
