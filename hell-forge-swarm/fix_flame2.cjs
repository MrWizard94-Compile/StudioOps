const fs = require('fs');
let code = fs.readFileSync('src/App.tsx', 'utf-8');
code = code.replace(/import \{ Flame,\s+motion,\s+AnimatePresence \} from "motion\/react";/m, 'import { motion, AnimatePresence } from "motion/react";');
fs.writeFileSync('src/App.tsx', code);
