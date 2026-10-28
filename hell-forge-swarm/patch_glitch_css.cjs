const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');

const newGlitch = `
const GlitchText = ({ text, active }: { text: string; active?: boolean }) => {
  return (
    <span className={\`inline-block \${active ? "glitch-effect text-white drop-shadow-[0_0_10px_rgba(255,0,0,0.8)]" : ""}\`} data-text={text}>
      {text}
    </span>
  );
};
`;

code = code.replace(/const GlitchText =[^;]+;\n\};\n/, newGlitch);
fs.writeFileSync('src/App.tsx', code);
