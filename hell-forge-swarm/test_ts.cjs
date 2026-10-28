const ts = require('typescript');
const src = ts.createSourceFile('t.tsx', 'const a = {;', ts.ScriptTarget.Latest, true, ts.ScriptKind.TSX);
console.log(src.parseDiagnostics);
