const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');

// 1. Add state
const statePattern = `  const [isEditingCustom, setIsEditingCustom] = useState<boolean>(false);`;
const newState = statePattern + `
  const [globalScanQueue, setGlobalScanQueue] = useState<string[]>([]);
  const [isGlobalScanActive, setIsGlobalScanActive] = useState<boolean>(false);
`;
code = code.replace(statePattern, newState);

// 2. Add useEffect
const useEffectPattern = `  // Fetch file list on mount`;
const newUseEffect = `
  // Global Scan logic
  useEffect(() => {
    if (isGlobalScanActive && !activeJobId) {
      if (globalScanQueue.length > 0) {
        const nextFile = globalScanQueue[0];
        setGlobalScanQueue(prev => prev.slice(1));
        handleInitiateSwarm(nextFile);
      } else {
        setIsGlobalScanActive(false);
      }
    }
  }, [isGlobalScanActive, activeJobId, globalScanQueue]);

` + useEffectPattern;
code = code.replace(useEffectPattern, newUseEffect);

// 3. Update handleInitiateSwarm
const oldHandle = `  const handleInitiateSwarm = async () => {`;
const newHandle = `  const handleInitiateSwarm = async (fileToScan?: string) => {`;
code = code.replace(oldHandle, newHandle);

const oldPayload = `      const payloadFile = selectedFile;`;
const newPayload = `      const payloadFile = typeof fileToScan === 'string' ? fileToScan : selectedFile;
      if (typeof fileToScan === 'string' && fileToScan !== selectedFile) {
        setSelectedFile(fileToScan);
      }`;
code = code.replace(oldPayload, newPayload);

// 4. Modify button
const oldButton = `                    <button
                      id="btn-initiate-swarm"
                      disabled={!!activeJobId}
                      onClick={handleInitiateSwarm}
                      className={\`w-full font-bold uppercase tracking-wider text-xs py-3 px-4 rounded transition-all duration-150 cursor-pointer \${activeJobId ? "bg-gradient-to-r from-red-900 to-orange-900 text-orange-400 animate-pulse border border-orange-500/50 shadow-[0_0_30px_rgba(234,88,12,0.5)]" : "bg-orange-600 hover:bg-orange-500 text-zinc-950 shadow-[0_0_15px_rgba(234,88,12,0.2)] hover:shadow-[0_0_20px_rgba(234,88,12,0.4)]"}\`}
                    >
                      {activeJobId ? (
                        <span className="flex items-center justify-center gap-2">
                          <RefreshCw className="h-3.5 w-3.5 animate-spin" /> <GlitchText text="HELL FORGE SMELTING..." active={true} />
                        </span>
                      ) : (
                        <span className="flex items-center justify-center gap-2">
                          <Play className="h-3.5 w-3.5" /> Ignite Hell Forge Optimizer
                        </span>
                      )}
                    </button>`;
                    
const newButton = `                    <div className="flex gap-2">
                      <button
                        id="btn-initiate-swarm"
                        disabled={!!activeJobId}
                        onClick={() => handleInitiateSwarm()}
                        className={\`flex-1 font-bold uppercase tracking-wider text-xs py-3 px-2 rounded transition-all duration-150 cursor-pointer \${activeJobId ? "bg-gradient-to-r from-red-900 to-orange-900 text-orange-400 animate-pulse border border-orange-500/50 shadow-[0_0_30px_rgba(234,88,12,0.5)]" : "bg-orange-600 hover:bg-orange-500 text-zinc-950 shadow-[0_0_15px_rgba(234,88,12,0.2)] hover:shadow-[0_0_20px_rgba(234,88,12,0.4)]"}\`}
                      >
                        {activeJobId ? (
                          <span className="flex items-center justify-center gap-2">
                            <RefreshCw className="h-3.5 w-3.5 animate-spin" /> <GlitchText text="SMELTING..." active={true} />
                          </span>
                        ) : (
                          <span className="flex items-center justify-center gap-2">
                            <Play className="h-3.5 w-3.5" /> Ignite File
                          </span>
                        )}
                      </button>
                      <button
                        id="btn-initiate-global"
                        disabled={!!activeJobId && !isGlobalScanActive}
                        onClick={() => {
                          if (isGlobalScanActive) {
                            setIsGlobalScanActive(false);
                            setGlobalScanQueue([]);
                          } else {
                            setGlobalScanQueue([...fileList]);
                            setIsGlobalScanActive(true);
                          }
                        }}
                        className={\`flex-1 font-bold uppercase tracking-wider text-xs py-3 px-2 rounded transition-all duration-150 cursor-pointer \${isGlobalScanActive ? "bg-red-600 hover:bg-red-500 text-white shadow-[0_0_15px_rgba(220,38,38,0.4)] animate-pulse" : "bg-zinc-800 hover:bg-zinc-700 text-white border border-zinc-700"}\`}
                      >
                        <span className="flex items-center justify-center gap-2">
                          <Activity className="h-3.5 w-3.5" /> {isGlobalScanActive ? \`Stop (\${globalScanQueue.length} left)\` : "Ignite All Files"}
                        </span>
                      </button>
                    </div>`;
                    
code = code.replace(oldButton, newButton);
fs.writeFileSync('src/App.tsx', code);
