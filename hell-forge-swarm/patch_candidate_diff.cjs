const fs = require('fs');
let code = fs.readFileSync('server.ts', 'utf-8');

const diffLogic = `
        const originalLines = originalCode.split('\\n').length;
        const newLines = rawCode.split('\\n').length;
        const diffLines = newLines - originalLines;
        
        job.candidates.push({
          id: agent.id,
          agentName: agent.name,
          agentType: agent.type,
          avatar: agent.avatar,
          unconventionalIdea: data.unconventionalIdea,
          code: rawCode,
          status: "pending",
          testLogs: [],
          score: 0,
          diffLines: diffLines > 0 ? "+" + diffLines : diffLines
        });
`;

code = code.replace(/job\.candidates\.push\(\{\n\s*id: agent\.id,\n\s*agentName: agent\.name,\n\s*agentType: agent\.type,\n\s*avatar: agent\.avatar,\n\s*unconventionalIdea: data\.unconventionalIdea,\n\s*code: rawCode,\n\s*status: "pending",\n\s*testLogs: \[\],\n\s*score: 0\n\s*\}\);/, diffLogic);
fs.writeFileSync('server.ts', code);
