const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');

const glitchComponent = `
const GlitchText = ({ text, active }: { text: string; active?: boolean }) => {
  return (
    <span className={\`relative inline-block \${active ? "animate-pulse" : ""}\`}>
      <span className="relative z-10">{text}</span>
      {active && (
        <>
          <span className="absolute top-0 left-[-1px] text-red-500 opacity-70 z-0 mix-blend-screen">{text}</span>
          <span className="absolute top-0 left-[1px] text-blue-500 opacity-70 z-0 mix-blend-screen">{text}</span>
        </>
      )}
    </span>
  );
};
`;

code = code.replace(/export default function App\(\) \{/, glitchComponent + '\nexport default function App() {');
fs.writeFileSync('src/App.tsx', code);
