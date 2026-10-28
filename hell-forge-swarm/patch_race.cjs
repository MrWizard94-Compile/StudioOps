const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');

code = code.replace(
  'const [isGlobalScanActive, setIsGlobalScanActive] = useState<boolean>(false);',
  'const [isGlobalScanActive, setIsGlobalScanActive] = useState<boolean>(false);\n  const [isInitiating, setIsInitiating] = useState<boolean>(false);'
);

code = code.replace(
  '  useEffect(() => {\n    if (isGlobalScanActive && !activeJobId) {\n      if (globalScanQueue.length > 0) {\n        const nextFile = globalScanQueue[0];\n        setGlobalScanQueue(prev => prev.slice(1));\n        handleInitiateSwarm(nextFile);\n      } else {\n        setIsGlobalScanActive(false);\n      }\n    }\n  }, [isGlobalScanActive, activeJobId, globalScanQueue]);',
  '  useEffect(() => {\n    if (isGlobalScanActive && !activeJobId && !isInitiating) {\n      if (globalScanQueue.length > 0) {\n        const nextFile = globalScanQueue[0];\n        setGlobalScanQueue(prev => prev.slice(1));\n        setIsInitiating(true);\n        handleInitiateSwarm(nextFile).finally(() => setIsInitiating(false));\n      } else {\n        setIsGlobalScanActive(false);\n      }\n    }\n  }, [isGlobalScanActive, activeJobId, globalScanQueue, isInitiating]);'
);

fs.writeFileSync('src/App.tsx', code);
