const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');

const scanlines = `
      {/* Global Scanline Overlay */}
      <div className="pointer-events-none fixed inset-0 z-[100] overflow-hidden opacity-10 mix-blend-overlay">
        <div className="absolute inset-0 bg-[linear-gradient(rgba(0,0,0,0)_50%,rgba(0,0,0,0.25)_50%),linear-gradient(90deg,rgba(255,0,0,0.06),rgba(0,255,0,0.02),rgba(0,0,255,0.06))] bg-[length:100%_4px,3px_100%]"></div>
      </div>
      
      {/* Active Job Overlay Sweep */}
      <AnimatePresence>
        {activeJobId && (
          <motion.div
            className="pointer-events-none fixed left-0 right-0 h-32 bg-gradient-to-b from-transparent via-orange-500/10 to-transparent z-[90]"
            initial={{ top: "-20%" }}
            animate={{ top: "120%" }}
            transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
          />
        )}
      </AnimatePresence>
`;

code = code.replace(/<div id="main-root"[^>]*>/, match => match + '\n' + scanlines);
fs.writeFileSync('src/App.tsx', code);
