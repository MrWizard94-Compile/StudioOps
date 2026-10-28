const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');

const particles = `
      {/* Background Particles when active */}
      <AnimatePresence>
        {activeJobId && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 0.1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 pointer-events-none z-0 overflow-hidden"
          >
            {[...Array(30)].map((_, i) => (
              <motion.div
                key={i}
                className="absolute w-1 h-1 bg-orange-500 rounded-full drop-shadow-[0_0_8px_rgba(234,88,12,1)]"
                initial={{
                  x: Math.random() * window.innerWidth,
                  y: window.innerHeight + 10,
                  opacity: Math.random() * 0.5 + 0.5
                }}
                animate={{
                  y: -10,
                  x: \`calc(\${Math.random() * window.innerWidth}px + \${Math.random() * 100 - 50}px)\`,
                  opacity: 0
                }}
                transition={{
                  duration: Math.random() * 3 + 2,
                  repeat: Infinity,
                  ease: "easeIn",
                  delay: Math.random() * 2
                }}
              />
            ))}
          </motion.div>
        )}
      </AnimatePresence>
`;

code = code.replace('{/* Dynamic Header */}', particles + '\n      {/* Dynamic Header */}');
fs.writeFileSync('src/App.tsx', code);
