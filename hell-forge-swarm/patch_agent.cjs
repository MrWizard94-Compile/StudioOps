const fs = require('fs');
let code = fs.readFileSync('server.ts', 'utf-8');

const newAgent = `      },
      {
        id: "hell_forge",
        name: "Hell-Forge-Overseer",
        type: "System Architect",
        avatar: "🔥",
        focus: "Transforming components into a dark, fiery, 'Hell Forge' aesthetic with deep reds/oranges, pulsing animations, and aggressive structural boundaries."
      }
    ];`;

code = code.replace(/      \}\n    \];/g, newAgent);
code = code.replace('Initializing 4 unique optimizer agents', 'Initializing 5 unique optimizer agents');
fs.writeFileSync('server.ts', code);
