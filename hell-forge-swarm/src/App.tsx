import React, { useState, useEffect, useRef } from "react";
import { 
  motion, 
  AnimatePresence 
} from "motion/react";
import { Flame, 
  Terminal, 
  Cpu, 
  Layers, 
  Github, 
  AlertTriangle, 
  CheckCircle, 
  Play, 
  RefreshCw, 
  FileCode, 
  Folder, 
  CheckCircle2, 
  Code, 
  Eye, 
  ChevronRight, 
  ShieldAlert, 
  Zap, 
  Sparkles, 
  Activity,
  Award,
  ArrowRight,
  Database,
  Search,
  Undo2
} from "lucide-react";


const GlitchText = ({ text, active }: { text: string; active?: boolean }) => {
  return (
    <span className={`relative inline-block ${active ? "animate-pulse" : ""}`}>
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

export default function App() {
  const [selectedFile, setSelectedFile] = useState<string>("src/App.tsx");
  const [fileList, setFileList] = useState<string[]>([]);
  const [fileContent, setFileContent] = useState<string>("");
  const [activeJobId, setActiveJobId] = useState<string | null>(null);
  const [jobState, setJobState] = useState<any>(null);
  const [selectedCandidateId, setSelectedCandidateId] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<"code" | "diff" | "testLogs">("code");
  const [isApplying, setIsApplying] = useState<boolean>(false);
  const [applyMessage, setApplyMessage] = useState<{ type: "success" | "error"; text: string } | null>(null);
  const [activeTab, setActiveTab] = useState<"workspace" | "proven">("workspace");
  const [provenImprovements, setForgedImprovements] = useState<any[]>([]);
  const [customFileContent, setCustomFileContent] = useState<string>("");
  const [isEditingCustom, setIsEditingCustom] = useState<boolean>(false);
  const [globalScanQueue, setGlobalScanQueue] = useState<string[]>([]);
  const [isGlobalScanActive, setIsGlobalScanActive] = useState<boolean>(false);
  const [isInitiating, setIsInitiating] = useState<boolean>(false);

  
  // Real-time container metrics simulation
  const [cpuUsage, setCpuUsage] = useState(12);
  const [memUsage, setMemUsage] = useState(42);
  const [furnaceTemp, setFurnaceTemp] = useState(450);
  const [activeContainers, setActiveContainers] = useState(1);

  const logsEndRef = useRef<HTMLDivElement>(null);


  // Global Scan logic
  useEffect(() => {
    if (isGlobalScanActive && !activeJobId && !isInitiating) {
      if (globalScanQueue.length > 0) {
        const nextFile = globalScanQueue[0];
        setGlobalScanQueue(prev => prev.slice(1));
        setIsInitiating(true);
        handleInitiateSwarm(nextFile).finally(() => setIsInitiating(false));
      } else {
        setIsGlobalScanActive(false);
      }
    }
  }, [isGlobalScanActive, activeJobId, globalScanQueue, isInitiating]);

  // Fetch file list on mount
  const fetchFiles = async () => {
    try {
      const res = await fetch("/api/files");
      const data = await res.json();
      if (data.files) {
        setFileList(data.files);
      }
    } catch (err) {
      console.error("Failed to load files", err);
    }
  };

  // Fetch content of selected file
  const fetchContent = async (path: string) => {
    try {
      const res = await fetch(`/api/file-content?path=${encodeURIComponent(path)}`);
      const data = await res.json();
      if (data.content) {
        setFileContent(data.content);
        setCustomFileContent(data.content);
      }
    } catch (err) {
      console.error("Failed to fetch file content", err);
    }
  };

  useEffect(() => {
    fetchFiles();
  }, []);

  useEffect(() => {
    if (selectedFile) {
      fetchContent(selectedFile);
    }
  }, [selectedFile]);

  // Keep logs scrolled to bottom
  useEffect(() => {
    if (logsEndRef.current) {
      logsEndRef.current.scrollIntoView({ behavior: "smooth" });
    }
  }, [jobState?.logs]);

  // Randomize container metrics for high-tech realism
  useEffect(() => {
    const timer = setInterval(() => {
      setCpuUsage((prev) => {
        const change = Math.floor(Math.random() * 5) - 2;
        const target = activeJobId ? 85 + change : 12 + change;
        return Math.max(5, Math.min(99, target));
      });
      setMemUsage((prev) => {
        const change = Math.floor(Math.random() * 3) - 1;
        const target = activeJobId ? 75 + change : 42 + change;
        return Math.max(20, Math.min(95, target));
      });
      setFurnaceTemp((prev) => {
        const change = Math.floor(Math.random() * 50) - 20;
        const target = activeJobId ? 2500 + change : 450 + change;
        // approach target
        return prev + (target - prev) * 0.2;
      });
      setActiveContainers(activeJobId ? 5 : 1);
    }, 2000);
    return () => clearInterval(timer);
  }, [activeJobId]);

  // Swarm Polling
  useEffect(() => {
    if (!activeJobId) return;

    const interval = setInterval(async () => {
      try {
        const res = await fetch(`/api/jobs/${activeJobId}`);
        if (!res.ok) throw new Error("Failed to load status");
        const data = await res.json();
        setJobState(data);

        // Auto-select candidate if none selected yet and candidates appear
        if (data.candidates && data.candidates.length > 0 && !selectedCandidateId) {
          setSelectedCandidateId(data.candidates[0].id);
        }

        if (data.status === "completed" || data.status === "failed") {
          setActiveJobId(null);
          // Save completed proven candidates
          if (data.status === "completed") {
            const proven = data.candidates.filter((c: any) => c.status === "proven");
            if (proven.length > 0) {
              setForgedImprovements((prev) => [
                ...prev,
                ...proven.map((p: any) => ({
                  ...p,
                  file: data.targetFile,
                  timestamp: new Date().toLocaleTimeString(),
                  originalCode: data.originalCode
                }))
              ]);
            }
          }
        }
      } catch (err) {
        console.error("Polling job status failed", err);
        setActiveJobId(null);
      }
    }, 1000);

    return () => clearInterval(interval);
  }, [activeJobId, selectedCandidateId]);

  // Run Swarm Optimizer
  const handleInitiateSwarm = async (fileToScan?: string) => {
    setApplyMessage(null);
    try {
      // If we made custom edits, write them virtually or warn
      const payloadFile = typeof fileToScan === 'string' ? fileToScan : selectedFile;
      if (typeof fileToScan === 'string' && fileToScan !== selectedFile) {
        setSelectedFile(fileToScan);
      }
      const res = await fetch("/api/run-swarm", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ filePath: payloadFile })
      });
      const data = await res.json();
      if (data.jobId) {
        setActiveJobId(data.jobId);
        setJobState({
          targetFile: payloadFile,
          status: "scanning",
          progress: 5,
          logs: [{ timestamp: new Date().toLocaleTimeString(), level: "info", message: "Connecting to swarm compiler hub..." }],
          candidates: [],
          openSourceInsights: []
        });
        setSelectedCandidateId(null);
        setViewMode("code");
      }
    } catch (err: any) {
      console.error(err);
      alert(`Initialization failed: ${err.message}`);
    }
  };

  // Apply Forged Code
  const handleApplyCode = async (codeToApply: string, targetPath: string) => {
    setIsApplying(true);
    setApplyMessage(null);
    try {
      const res = await fetch("/api/apply-improvement", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ filePath: targetPath, code: codeToApply })
      });
      const data = await res.json();
      if (data.success) {
        setApplyMessage({
          type: "success",
          text: `Applied successfully! Clean build compiled. Local backup saved as ${data.backup}.`
        });
        // Reload current file view
        fetchContent(targetPath);
      } else {
        setApplyMessage({ type: "error", text: data.error || "Failed to apply improvement code." });
      }
    } catch (err: any) {
      setApplyMessage({ type: "error", text: err.message });
    } finally {
      setIsApplying(false);
    }
  };

  // Restore backup
  const handleRestoreBackup = async () => {
    setIsApplying(true);
    setApplyMessage(null);
    try {
      const res = await fetch("/api/restore-backup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ filePath: selectedFile })
      });
      const data = await res.json();
      if (data.success) {
        setApplyMessage({ type: "success", text: "Successfully rolled back and compiled original source backup." });
        fetchContent(selectedFile);
      } else {
        setApplyMessage({ type: "error", text: data.error || "No backup file found to restore." });
      }
    } catch (err: any) {
      setApplyMessage({ type: "error", text: err.message });
    } finally {
      setIsApplying(false);
    }
  };

  // Helper to generate simple side-by-side diff markers
  const renderCodeDiff = (original: string, modified: string) => {
    const origLines = original.split("\n");
    const modLines = modified.split("\n");
    const maxLength = Math.max(origLines.length, modLines.length);

    const diffRows = [];
    for (let i = 0; i < maxLength; i++) {
      const origLine = origLines[i] !== undefined ? origLines[i] : "";
      const modLine = modLines[i] !== undefined ? modLines[i] : "";
      const isDifferent = origLine !== modLine;

      diffRows.push(
        <div key={i} className={`grid grid-cols-2 text-[11px] font-mono border-b border-zinc-900/60 ${isDifferent ? "bg-amber-950/10" : ""}`}>
          <div className={`p-1.5 pl-3 border-r border-zinc-800/80 flex items-start select-all ${isDifferent ? "bg-rose-950/20 text-rose-300" : "text-zinc-500"}`}>
            <span className="w-8 select-none text-zinc-600 inline-block text-right pr-2">{i + 1}</span>
            <pre className="whitespace-pre-wrap break-all">{origLine}</pre>
          </div>
          <div className={`p-1.5 pl-3 flex items-start select-all ${isDifferent ? "bg-orange-950/20 text-orange-300" : "text-zinc-300"}`}>
            <span className="w-8 select-none text-zinc-600 inline-block text-right pr-2">{i + 1}</span>
            <pre className="whitespace-pre-wrap break-all">{modLine}</pre>
          </div>
        </div>
      );
    }
    return <div className="divide-y divide-zinc-900/60 overflow-y-auto max-h-[400px] bg-zinc-950 rounded">{diffRows}</div>;
  };

  const selectedCandidate = jobState?.candidates?.find((c: any) => c.id === selectedCandidateId);

  return (
    <div id="main-root" className="min-h-screen bg-zinc-950 text-zinc-200 flex flex-col font-sans selection:bg-orange-500/30 selection:text-orange-300 select-none">

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
                  x: `calc(${Math.random() * window.innerWidth}px + ${Math.random() * 100 - 50}px)`,
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

      {/* Dynamic Header */}
      <header id="app-header" className="bg-zinc-950/80 backdrop-blur-md border-b border-zinc-800 px-6 py-4 flex flex-wrap justify-between items-center gap-4 relative overflow-hidden">
        {/* Glow decoration */}
        <div className="absolute top-0 left-1/4 w-96 h-px bg-gradient-to-r from-transparent via-orange-500/50 to-transparent blur-sm"></div>
        <div className="absolute top-0 right-1/4 w-96 h-px bg-gradient-to-r from-transparent via-red-500/50 to-transparent blur-sm"></div>
        
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 bg-orange-500 rounded flex items-center justify-center font-bold text-zinc-950 shadow-[0_0_15px_rgba(234,88,12,0.3)] shrink-0">
            <Flame className="h-4 w-4 text-zinc-950 fill-zinc-950" />
          </div>
          <div>
            <h1 className="text-xs font-bold tracking-widest text-white uppercase font-display flex items-center gap-2">
              <GlitchText text="HELL-FORGE SWARM" active={!!activeJobId} /> <span className="text-[10px] bg-orange-500/10 text-orange-400 border border-orange-500/20 px-1.5 py-0.5 rounded font-mono uppercase tracking-wider font-semibold">v2.1</span>
            </h1>
            <p className="text-[10px] text-zinc-400 font-mono tracking-widest uppercase leading-none mt-1">Autonomous Double-Incineration Compiler Sandbox</p>
          </div>
        </div>

        {/* Real-time container metrics */}
        <div id="metrics-panel" className="flex items-center gap-8">
          <div className="flex flex-col items-end">
            <span className="text-[10px] text-zinc-500 uppercase font-bold tracking-wider mb-0.5">SANDBOX ENV</span>
            <span className="text-xs font-mono text-orange-400 font-semibold flex items-center gap-1.5">
              <span className="w-1.5 h-1.5 rounded-full bg-orange-400 animate-ping"></span>
              Docker v26.1
            </span>
          </div>
          <div className="flex flex-col items-end border-l border-zinc-800 pl-6">
            <span className="text-[10px] text-zinc-500 uppercase font-bold tracking-wider mb-0.5">CORE CPU</span>
            <span className="text-xs font-mono text-red-400 font-semibold">{cpuUsage}%</span>
          </div>
          <div className="flex flex-col items-end border-l border-zinc-800 pl-6">
            <span className="text-[10px] text-zinc-500 uppercase font-bold tracking-wider mb-0.5">CORE MEMORY</span>
            <span className="text-xs font-mono text-amber-400 font-semibold">{memUsage}%</span>
          </div>
          <div className="flex flex-col items-end border-l border-zinc-800 pl-6">
            <span className="text-[10px] text-zinc-500 uppercase font-bold tracking-wider mb-0.5">FURNACE TEMP</span>
            <span className={`text-xs font-mono font-semibold ${furnaceTemp > 1500 ? 'text-orange-500 animate-pulse drop-shadow-[0_0_5px_rgba(249,115,22,0.8)]' : 'text-zinc-400'}`}>
              {Math.round(furnaceTemp)}°C
            </span>
          </div>
          <div className="flex flex-col items-end border-l border-zinc-800 pl-6">
            <span className="text-[10px] text-zinc-500 uppercase font-bold tracking-wider mb-0.5">ACTIVE NODES</span>
            <span className="text-xs font-mono text-orange-400 font-semibold">{activeContainers} / 5</span>
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main id="app-main-layout" className="flex-1 max-w-7xl w-full mx-auto p-4 lg:p-6 grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        
        {/* Navigation & Tab Selection */}
        <div className="lg:col-span-12 flex items-center justify-between border-b border-zinc-800 pb-px">
          <div className="flex gap-4">
            <button 
              id="tab-workspace"
              onClick={() => setActiveTab("workspace")}
              className={`pb-2 px-1 text-xs font-display uppercase tracking-wider font-semibold transition-all duration-200 flex items-center gap-2 ${
                activeTab === "workspace" 
                  ? "text-white border-b-2 border-orange-500" 
                  : "text-zinc-500 hover:text-zinc-300"
              }`}
            >
              <Code className="h-3.5 w-3.5" /> Crucible Compiler
            </button>
            <button 
              id="tab-proven"
              onClick={() => setActiveTab("proven")}
              className={`pb-2 px-1 text-xs font-display uppercase tracking-wider font-semibold transition-all duration-200 flex items-center gap-2 ${
                activeTab === "proven" 
                  ? "text-white border-b-2 border-orange-500" 
                  : "text-zinc-500 hover:text-zinc-300"
              }`}
            >
              <Award className="h-3.5 w-3.5" /> Forged Artifacts Archive ({provenImprovements.length})
            </button>
          </div>

          <div className="text-[10px] text-zinc-500 font-mono uppercase tracking-wider">
            Target Focus: <span className="text-orange-400">Recursive self-improvement pipeline</span>
          </div>
        </div>

        {activeTab === "workspace" && (
          <>
            {/* LEFT COLUMN: Local Workspace Code Explorer */}
            <div id="left-column" className="lg:col-span-4 space-y-6">
              <div id="explorer-card" className="bg-zinc-900/40 border border-zinc-800/80 rounded-lg overflow-hidden">
                <div className="p-3 border-b border-zinc-800 flex justify-between items-center bg-zinc-800/20">
                  <h2 className="text-[10px] font-bold uppercase text-zinc-400 tracking-wider font-display flex items-center gap-2">
                    <Folder className="h-3.5 w-3.5 text-red-400" /> Workspace Directory
                  </h2>
                </div>
                
                {/* File selectors */}
                <div className="p-3">
                  <div className="space-y-1 max-h-[180px] overflow-y-auto pr-1 bg-zinc-950 p-2 rounded border border-zinc-800/60 font-mono text-[11px]">
                    {fileList.map((file) => {
                      const isActive = selectedFile === file;
                      return (
                        <button
                          key={file}
                          id={`file-${file.replace(/\//g, "-")}`}
                          onClick={() => setSelectedFile(file)}
                          className={`w-full text-left px-2.5 py-1.5 rounded text-[11px] font-mono flex items-center justify-between transition-all duration-150 ${
                            isActive 
                              ? "bg-orange-500/10 text-orange-300 border border-orange-500/30 font-semibold" 
                              : "text-zinc-400 hover:text-white hover:bg-zinc-800/50"
                          }`}
                        >
                          <span className="flex items-center gap-2 truncate">
                            <FileCode className={`h-3.5 w-3.5 ${isActive ? "text-orange-400" : "text-zinc-500"}`} />
                            {file}
                          </span>
                          {isActive && <ChevronRight className="h-3 w-3 text-orange-400" />}
                        </button>
                      );
                    })}
                  </div>

                  <div className="mt-4 pt-4 border-t border-zinc-800/60 space-y-3">
                    <div className="bg-zinc-950 p-3 rounded border border-zinc-800/60 text-[11px] leading-relaxed text-zinc-400 font-mono">
                      <span className="text-white font-semibold block mb-1">Self-Improvement Priority:</span>
                      The system prioritizes target code modification on itself to optimize internal engines, styling, and compile-safety autonomously.
                    </div>

                    <div className="flex gap-2">
                      <button
                        id="btn-initiate-swarm"
                        disabled={!!activeJobId}
                        onClick={() => handleInitiateSwarm()}
                        className={`flex-1 font-bold uppercase tracking-wider text-xs py-3 px-2 rounded transition-all duration-150 cursor-pointer ${activeJobId ? "bg-gradient-to-r from-red-900 to-orange-900 text-orange-400 animate-pulse border border-orange-500/50 shadow-[0_0_30px_rgba(234,88,12,0.5)]" : "bg-orange-600 hover:bg-orange-500 text-zinc-950 shadow-[0_0_15px_rgba(234,88,12,0.2)] hover:shadow-[0_0_20px_rgba(234,88,12,0.4)]"}`}
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
                        className={`flex-1 font-bold uppercase tracking-wider text-xs py-3 px-2 rounded transition-all duration-150 cursor-pointer ${isGlobalScanActive ? "bg-red-600 hover:bg-red-500 text-white shadow-[0_0_15px_rgba(220,38,38,0.4)] animate-pulse" : "bg-zinc-800 hover:bg-zinc-700 text-white border border-zinc-700"}`}
                      >
                        <span className="flex items-center justify-center gap-2">
                          <Activity className="h-3.5 w-3.5" /> {isGlobalScanActive ? `Stop (${globalScanQueue.length} left)` : "Ignite All Files"}
                        </span>
                      </button>
                    </div>

                    {/* Backup actions */}
                    <div className="flex gap-2">
                      <button
                        id="btn-restore-backup"
                        onClick={handleRestoreBackup}
                        disabled={isApplying}
                        className="flex-1 bg-zinc-900 border border-zinc-800 hover:bg-zinc-800 hover:text-white text-zinc-400 font-semibold py-1.5 px-2.5 rounded text-[10px] flex items-center justify-center gap-1.5 transition-all cursor-pointer"
                        title="Rolls back the target file to its prior state if compiler issues are encountered after deployment."
                      >
                        <Undo2 className="h-3 w-3" /> Restore Previous Backup
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              {/* Crawled Open-Source Insights */}
              <div id="crawled-insights-card" className="bg-zinc-900/40 border border-zinc-800/80 rounded-lg overflow-hidden">
                <div className="p-3 border-b border-zinc-800 bg-zinc-800/20">
                  <h3 className="text-[10px] font-bold uppercase text-zinc-400 tracking-wider font-display flex items-center gap-2">
                    <Github className="h-3.5 w-3.5 text-orange-400" /> Crawled Open-Source Bits
                  </h3>
                </div>
                
                <div className="p-3 space-y-3">
                  {jobState?.openSourceInsights && jobState.openSourceInsights.length > 0 ? (
                    <div className="space-y-3">
                      {jobState.openSourceInsights.map((insight: any, idx: number) => (
                        <div key={idx} className="p-2.5 bg-zinc-950 rounded border border-zinc-800/60">
                          <div className="flex items-center justify-between gap-2 mb-1.5">
                            <span className="text-[11px] text-white font-semibold truncate hover:underline cursor-pointer flex items-center gap-1.5">
                              <span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse"></span>
                              {insight.title}
                            </span>
                            <span className="text-[9px] bg-orange-500/10 text-orange-400 border border-orange-500/20 px-1.5 py-0.5 rounded font-mono">
                              {insight.license}
                            </span>
                          </div>
                          <p className="text-[10px] text-zinc-400 leading-relaxed font-mono">
                            "{insight.snippet}"
                          </p>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className="text-center py-6 border border-dashed border-zinc-800/40 rounded">
                      <Search className="h-4 w-4 text-zinc-600 mx-auto mb-2" />
                      <p className="text-[10px] text-zinc-500 font-mono">No active crawl insights cached. Launch Swarm to trigger crawler pipeline.</p>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* MIDDLE/RIGHT COLUMN: Pipeline Logs, Swarm Candidates, Falsification & Interactive Console */}
            <div id="right-column" className="lg:col-span-8 space-y-6">
              
              {/* Active Pipeline Progress */}
              <AnimatePresence>
                {jobState && (
                  <motion.div 
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="bg-zinc-900/40 border border-zinc-800/80 rounded-lg p-5"
                  >
                    <div className="flex justify-between items-center mb-3">
                      <span className="text-[10px] font-bold text-orange-400 flex items-center gap-1.5 uppercase tracking-wider font-mono">
                        <Activity className="h-3.5 w-3.5" /> Forge State: {jobState.status}
                      </span>
                      <span className="text-xs font-mono font-bold text-zinc-300">{jobState.progress}%</span>
                    </div>

                    {/* Progress bar */}
                    <div className="w-full bg-zinc-950 rounded-full h-1 overflow-hidden">
                      <div 
                        className="bg-gradient-to-r from-orange-500 via-red-500 to-amber-500 h-1 rounded-full transition-all duration-300"
                        style={{ width: `${jobState.progress}%` }}
                      ></div>
                    </div>

                    {/* Stage descriptions */}
                    <div className="grid grid-cols-6 gap-1 mt-4 text-[9px] text-center font-mono uppercase tracking-wider">
                      {[
                        { name: "Scan", active: jobState.progress >= 5, done: jobState.progress > 5 },
                        { name: "Crawl", active: jobState.progress >= 20, done: jobState.progress > 20 },
                        { name: "Swarm", active: jobState.progress >= 40, done: jobState.progress > 40 },
                        { name: "Falsify", active: jobState.progress >= 65, done: jobState.progress > 65 },
                        { name: "Refine", active: jobState.progress >= 85, done: jobState.progress > 85 },
                        { name: "Forged", active: jobState.progress === 100, done: jobState.progress === 100 }
                      ].map((stage, idx) => (
                        <div key={idx} className="flex flex-col items-center">
                          <div className={`h-2 w-2 rounded-full mb-1 ${
                            stage.done ? "bg-orange-500" : stage.active ? "bg-red-400 animate-ping" : "bg-zinc-800"
                          }`} />
                          <span className={stage.active ? "text-orange-400 font-bold" : "text-zinc-500"}>{stage.name}</span>
                        </div>
                      ))}
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>

              {/* Interactive Console Terminal Output */}
              <div id="terminal-card" className="bg-zinc-900 border border-zinc-800 rounded-lg overflow-hidden shadow-2xl">
                <div className="bg-zinc-950 px-4 py-2 border-b border-zinc-800 flex justify-between items-center text-[10px] text-zinc-400 font-mono uppercase tracking-widest">
                  <div className="flex items-center gap-2">
                    <Terminal className="h-4 w-4 text-orange-400" />
                    <span>SANDBOX_COMPILE_CONSOLE_LOGS</span>
                  </div>
                  <div className="flex gap-1.5">
                    <span className="w-2 h-2 rounded-full bg-zinc-800"></span>
                    <span className="w-2 h-2 rounded-full bg-zinc-800"></span>
                    <span className="w-2 h-2 rounded-full bg-orange-500"></span>
                  </div>
                </div>
                
                <div className="p-4 bg-zinc-950 font-mono text-[11px] leading-relaxed max-h-[220px] overflow-y-auto space-y-1.5 scrollbar-thin">
                  {jobState?.logs && jobState.logs.length > 0 ? (
                    jobState.logs.map((log: any, idx: number) => {
                      let color = "text-zinc-400";
                      let prefix = "[INFO]";
                      if (log.level === "success") { color = "text-orange-400"; prefix = "[OK]"; }
                      if (log.level === "warn") { color = "text-amber-400"; prefix = "[WARN]"; }
                      if (log.level === "error") { color = "text-rose-500 font-semibold"; prefix = "[FAIL]"; }
                      
                      return (
                        <div key={idx} className={`${color} flex items-start gap-2 text-[11px]`}>
                          <span className="text-zinc-600 select-none">[{log.timestamp}]</span>
                          <span className="font-bold select-none min-w-[45px] inline-block">{prefix}</span>
                          <span className="break-all whitespace-pre-wrap">{log.message}</span>
                        </div>
                      );
                    })
                  ) : (
                    <div className="text-zinc-600 text-center py-8 font-mono">
                      Console Idle. Select a target file and trigger Swarm sandbox.
                    </div>
                  )}
                  <div ref={logsEndRef} />
                </div>
              </div>

              {/* CANDIDATES COMPARISON & VERDICT SHIELD */}
              {jobState?.candidates && jobState.candidates.length > 0 && (
                <div id="candidates-container" className="grid grid-cols-1 md:grid-cols-12 gap-5">
                  
                  {/* Candidates List (Left) */}
                  <div className="md:col-span-5 space-y-2.5">
                    <h3 className="text-[10px] font-bold text-zinc-400 uppercase tracking-wider font-mono mb-2">Furnace Processing Verdicts</h3>
                    {jobState.candidates.map((candidate: any) => {
                      const isSelected = selectedCandidateId === candidate.id;
                      
                      let statusBadge = null;
                      if (candidate.status === "pending") {
                        statusBadge = <span className="text-[10px] text-zinc-500 font-mono uppercase tracking-wider animate-pulse">Pending</span>;
                      } else if (candidate.status === "falsifying") {
                        statusBadge = <span className="text-[10px] text-red-400 border border-red-500/20 bg-red-500/10 px-1.5 py-0.5 rounded font-mono uppercase tracking-wider animate-pulse flex items-center gap-1"><RefreshCw className="h-2.5 w-2.5 animate-spin" /> Incinerating</span>;
                      } else if (candidate.status === "falsified") {
                        statusBadge = <span className="text-[10px] text-rose-500 border border-rose-500/20 bg-rose-500/10 px-1.5 py-0.5 rounded font-mono uppercase tracking-wider font-semibold">Incinerated</span>;
                      } else if (candidate.status === "refining") {
                        statusBadge = <span className="text-[10px] text-amber-400 border border-amber-500/20 bg-amber-500/10 px-1.5 py-0.5 rounded font-mono uppercase tracking-wider">Refining</span>;
                      } else if (candidate.status === "proven") {
                        statusBadge = <span className="text-[10px] text-orange-400 border border-orange-500/20 bg-orange-500/10 px-1.5 py-0.5 rounded font-mono uppercase tracking-wider font-bold">Forged</span>;
                      }

                      return (
                        <button
                          key={candidate.id}
                          id={`candidate-btn-${candidate.id}`}
                          onClick={() => {
                            setSelectedCandidateId(candidate.id);
                            setViewMode("code");
                          }}
                          className={`w-full text-left p-3.5 rounded-lg border transition-all duration-150 flex items-center justify-between cursor-pointer ${
                            isSelected 
                              ? "bg-zinc-900 border-l-2 border-l-orange-500 border-zinc-800" 
                              : "bg-zinc-900/40 border-zinc-800/80 hover:bg-zinc-900/60"
                          }`}
                        >
                          <div className="flex items-center gap-3">
                            <span className="text-2xl">{candidate.avatar}</span>
                            <div>
                              <div className="text-xs font-bold text-white leading-tight flex items-center gap-1.5 uppercase tracking-wide font-display">
                                {candidate.agentName}
                              </div>
                              <span className="text-[10px] text-zinc-500 font-mono">{candidate.agentType}</span>
                            </div>
                          </div>
                          <div>{statusBadge}</div>
                        </button>
                      );
                    })}
                  </div>

                  {/* Inspector Console Panel (Right) */}
                  <div className="md:col-span-7 bg-zinc-900 rounded-lg border border-zinc-800 overflow-hidden shadow-2xl flex flex-col">
                    {selectedCandidate ? (
                      <>
                        <div className="bg-zinc-950 px-4 py-2 border-b border-zinc-800 flex flex-wrap justify-between items-center gap-2">
                          <div className="flex items-center gap-2">
                            <span className="text-xl">{selectedCandidate.avatar}</span>
                            <div>
                              <h4 className="text-[11px] font-bold text-white font-display uppercase tracking-wider">{selectedCandidate.agentName}</h4>
                              <p className="text-[9px] text-zinc-500 font-mono">Score index: <span className="text-orange-400">{selectedCandidate.score}</span>/100 | Diff: <span className="text-orange-500 font-bold">{selectedCandidate.diffLines}</span> lines</p>
                            </div>
                          </div>

                          <div className="flex gap-1.5">
                            <button
                              id="btn-inspect-code"
                              onClick={() => setViewMode("code")}
                              className={`px-2.5 py-1 rounded text-[10px] font-mono uppercase tracking-wider transition-all cursor-pointer ${
                                viewMode === "code" ? "bg-zinc-800 text-white border border-zinc-700" : "text-zinc-500 hover:text-zinc-300"
                              }`}
                            >
                              Code
                            </button>
                            <button
                              id="btn-inspect-diff"
                              onClick={() => setViewMode("diff")}
                              className={`px-2.5 py-1 rounded text-[10px] font-mono uppercase tracking-wider transition-all cursor-pointer ${
                                viewMode === "diff" ? "bg-zinc-800 text-white border border-zinc-700" : "text-zinc-500 hover:text-zinc-300"
                              }`}
                            >
                              Diff
                            </button>
                            <button
                              id="btn-inspect-logs"
                              onClick={() => setViewMode("testLogs")}
                              className={`px-2.5 py-1 rounded text-[10px] font-mono uppercase tracking-wider transition-all cursor-pointer ${
                                viewMode === "testLogs" ? "bg-zinc-800 text-white border border-zinc-700" : "text-zinc-500 hover:text-zinc-300"
                              }`}
                            >
                              Tests ({selectedCandidate.testLogs.length})
                            </button>
                          </div>
                        </div>

                        {/* Inspector Body */}
                        <div className="p-4 flex-1 flex flex-col min-h-[340px]">
                          {/* Unconventional idea explanation */}
                          <div className="bg-zinc-950 border border-zinc-800 p-3 rounded text-[11px] leading-relaxed text-red-300 font-mono mb-4">
                            <span className="text-white font-bold block text-[10px] uppercase tracking-wider mb-1">Unconventional Idea:</span>
                            "{selectedCandidate.unconventionalIdea}"
                          </div>

                          {/* Content view modes */}
                          <div className="flex-1 flex flex-col">
                            {viewMode === "code" && (
                              <div className="relative flex-1 flex flex-col">
                                <div className="absolute top-2 right-2 bg-zinc-900 px-2 py-0.5 rounded text-[9px] font-mono border border-zinc-800 text-zinc-500 uppercase">
                                  READ-ONLY CACHE
                                </div>
                                <pre className="p-4 bg-zinc-950 rounded text-[11px] font-mono text-zinc-300 overflow-auto max-h-[280px] border border-zinc-800/60 select-text leading-relaxed">
                                  <code>{selectedCandidate.code}</code>
                                </pre>
                              </div>
                            )}

                            {viewMode === "diff" && (
                              <div className="border border-zinc-800/80 rounded overflow-hidden">
                                {renderCodeDiff(jobState.originalCode, selectedCandidate.code)}
                              </div>
                            )}

                            {viewMode === "testLogs" && (
                              <div className="bg-zinc-950 p-4 rounded border border-zinc-800/60 font-mono text-[11px] text-zinc-300 space-y-2 max-h-[280px] overflow-auto">
                                <div className="text-zinc-500 font-bold mb-1 border-b border-zinc-800/60 pb-1 uppercase tracking-wider text-[10px]">
                                  Hell Forge Crucible Logs
                                </div>
                                {selectedCandidate.testLogs.map((log: string, idx: number) => {
                                  let style = "text-zinc-400";
                                  if (log.includes("PASSED")) style = "text-orange-400 font-medium";
                                  if (log.includes("FAILED")) style = "text-rose-400 bg-rose-950/10 p-1.5 rounded border border-rose-900/20";
                                  if (log.includes("AUDIT")) style = "text-amber-400";
                                  return (
                                    <div key={idx} className={`${style} leading-relaxed whitespace-pre-wrap break-all`}>
                                      ➜ {log}
                                    </div>
                                  );
                                })}
                              </div>
                            )}
                          </div>

                          {/* Render apply button for proven options */}
                          {selectedCandidate.status === "proven" && (
                            <div className="mt-4 pt-4 border-t border-zinc-800/60">
                              <button
                                id="btn-apply-proven-candidate"
                                disabled={isApplying}
                                onClick={() => handleApplyCode(selectedCandidate.code, jobState.targetFile)}
                                className="w-full bg-orange-600 hover:bg-orange-500 text-zinc-950 font-bold py-3 px-4 rounded text-xs uppercase tracking-wider flex items-center justify-center gap-2 shadow-[0_0_15px_rgba(234,88,12,0.2)] transition-all cursor-pointer"
                              >
                                {isApplying ? (
                                  <>
                                    <RefreshCw className="h-4 w-4 animate-spin" /> Deploying Improved File...
                                  </>
                                ) : (
                                  <>
                                    <CheckCircle2 className="h-4 w-4" /> Apply & Deploy Forged Code to Live App
                                  </>
                                )}
                              </button>
                            </div>
                          )}

                          {selectedCandidate.status === "falsified" && (
                            <div className="mt-4 p-3 bg-rose-950/20 border border-rose-900/30 rounded text-center text-rose-400 text-[11px] font-mono flex items-center justify-center gap-2">
                              <AlertTriangle className="h-4 w-4 shrink-0 text-rose-500" /> Candidates failing compilation are strictly falsified & discarded.
                            </div>
                          )}
                        </div>
                      </>
                    ) : (
                      <div className="flex-1 flex flex-col justify-center items-center text-center p-8">
                        <Terminal className="h-8 w-8 text-zinc-700 mb-3 animate-pulse" />
                        <p className="text-xs text-zinc-500 font-mono">Select an agent node on the left to inspect sandboxed improvement candidates, view source diffs, or check compiler logs.</p>
                      </div>
                    )}
                  </div>

                </div>
              )}

              {/* Status messages */}
              {applyMessage && (
                <div 
                  id="apply-feedback-alert"
                  className={`p-4 rounded text-xs font-mono border ${
                    applyMessage.type === "success" 
                      ? "bg-orange-500/10 text-orange-300 border-orange-500/30" 
                      : "bg-rose-500/10 text-rose-300 border-rose-500/30"
                  }`}
                >
                  <div className="flex items-start gap-2">
                    {applyMessage.type === "success" ? <CheckCircle className="h-4 w-4 text-orange-400 shrink-0" /> : <AlertTriangle className="h-4 w-4 text-rose-400 shrink-0" />}
                    <div>
                      <p className="font-bold uppercase tracking-wider mb-0.5">{applyMessage.type === "success" ? "System Compiled Successfully" : "Deployment Error"}</p>
                      <p>{applyMessage.text}</p>
                    </div>
                  </div>
                </div>
              )}

              {/* Default IDE preview block when no job is active */}
              {!jobState && (
                <div id="ide-preview-card" className="bg-zinc-900/40 border border-zinc-800 rounded-lg overflow-hidden shadow-2xl">
                  <div className="bg-zinc-950 px-4 py-3 border-b border-zinc-800 flex justify-between items-center">
                    <span className="text-[11px] font-bold text-zinc-400 font-mono uppercase tracking-wider">Live File Reader: {selectedFile}</span>
                    <span className="text-[9px] bg-orange-500/10 text-orange-400 border border-orange-500/20 px-2 py-0.5 rounded font-mono uppercase tracking-wider font-semibold">Sync Mode: Active</span>
                  </div>
                  
                  <div className="p-4 bg-zinc-950 overflow-auto max-h-[380px] border-b border-zinc-800 font-mono text-[11px] text-zinc-400 select-text">
                    {fileContent ? (
                      fileContent.split("\n").map((line, idx) => (
                        <div key={idx} className="flex hover:bg-zinc-900/20">
                          <span className="w-10 select-none text-zinc-600 text-right pr-3.5 border-r border-zinc-900 mr-3">{idx + 1}</span>
                          <pre className="whitespace-pre-wrap break-all text-zinc-300">{line}</pre>
                        </div>
                      ))
                    ) : (
                      <div className="text-center py-12 text-zinc-600">
                        <RefreshCw className="h-5 w-5 animate-spin mx-auto mb-2 text-orange-400" />
                        Loading file content...
                      </div>
                    )}
                  </div>
                </div>
              )}

            </div>
          </>
        )}

        {activeTab === "proven" && (
          <div className="lg:col-span-12 space-y-6">
            <div id="proven-archive-card" className="bg-zinc-900/40 border border-zinc-800 rounded-lg p-6 shadow-xl">
              <div className="flex items-center gap-3 mb-6">
                <div className="p-2 bg-orange-500/10 border border-orange-500/20 rounded">
                  <Award className="h-6 w-6 text-orange-400" />
                </div>
                <div>
                  <h2 className="text-sm font-bold text-white uppercase tracking-wider font-display">Forged Optimizations Catalog</h2>
                  <p className="text-[10px] text-zinc-400 font-mono uppercase tracking-widest leading-none mt-1">Survival archive of all swarm candidates that successfully passed double-falsification testing.</p>
                </div>
              </div>

              {provenImprovements.length > 0 ? (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {provenImprovements.map((proven, idx) => (
                    <div key={idx} className="p-4 bg-zinc-950 rounded border border-zinc-800 flex flex-col justify-between hover:border-zinc-700 transition">
                      <div>
                        <div className="flex justify-between items-start mb-3">
                          <div className="flex items-center gap-2">
                            <span className="text-2xl">{proven.avatar}</span>
                            <div>
                              <h4 className="text-xs font-bold text-white uppercase font-display tracking-wider">{proven.agentName}</h4>
                              <p className="text-[9px] text-zinc-500 font-mono">Target: {proven.file}</p>
                            </div>
                          </div>
                          <span className="text-[9px] bg-orange-500/10 text-orange-400 border border-orange-500/20 px-2 py-0.5 rounded font-mono font-bold uppercase tracking-wider">
                            Forged ({proven.score}/100)
                          </span>
                        </div>

                        <p className="text-xs text-zinc-300 mb-4 bg-zinc-900/40 p-3 rounded border border-zinc-800/40 font-mono leading-relaxed">
                          "{proven.unconventionalIdea}"
                        </p>
                      </div>

                      <div className="flex gap-2">
                        <button
                          onClick={() => {
                            setSelectedFile(proven.file);
                            setActiveTab("workspace");
                            // Set artificial state to let user see candidate
                            setJobState({
                              targetFile: proven.file,
                              originalCode: proven.originalCode,
                              status: "completed",
                              progress: 100,
                              logs: [{ timestamp: proven.timestamp, level: "success", message: "Archived proven candidate loaded from history." }],
                              candidates: [proven]
                            });
                            setSelectedCandidateId(proven.id);
                            setViewMode("diff");
                          }}
                          className="flex-1 bg-zinc-900 border border-zinc-800 hover:bg-zinc-800 text-zinc-300 font-semibold py-2 rounded text-xs transition flex items-center justify-center gap-1.5 uppercase tracking-wider font-mono cursor-pointer"
                        >
                          <Eye className="h-3.5 w-3.5" /> View Source Diff
                        </button>
                        <button
                          onClick={() => handleApplyCode(proven.code, proven.file)}
                          className="flex-1 bg-orange-600 hover:bg-orange-500 text-zinc-950 font-bold py-2 rounded text-xs transition flex items-center justify-center gap-1.5 uppercase tracking-wider shadow-[0_0_15px_rgba(234,88,12,0.2)] cursor-pointer"
                        >
                          <CheckCircle2 className="h-3.5 w-3.5 text-zinc-950" /> Apply Code
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-16 border border-dashed border-zinc-800/40 rounded">
                  <Award className="h-8 w-8 text-zinc-700 mx-auto mb-3 animate-pulse" />
                  <h3 className="text-xs font-bold text-zinc-400 uppercase tracking-wider font-mono">No improvements archived yet</h3>
                  <p className="text-[10px] text-zinc-500 max-w-sm mx-auto mt-2 font-mono">Initiate sandbox optimization swarms on any local file. Survivor code candidates will appear here once certified.</p>
                </div>
              )}
            </div>
          </div>
        )}

      </main>

      {/* Footer */}
      <footer className="mt-auto h-8 bg-zinc-900 border-t border-zinc-800 flex items-center px-6 justify-between text-[10px] text-zinc-500 font-mono">
        <div className="flex gap-4">
          <span className="flex items-center gap-1.5">
            <span className="w-1.5 h-1.5 rounded-full bg-orange-500"></span> DB: Synchronized
          </span>
          <span>UPTIME: 42:12:05</span>
        </div>
        <div className="flex gap-4">
          <span>RECURSIVE MODE: <span className="text-orange-400 uppercase">Enabled</span></span>
          <span>DIVERSITY RATIO: <span className="text-amber-400">0.84</span></span>
        </div>
      </footer>
    </div>
  );
}
