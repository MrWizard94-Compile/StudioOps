import { createHotContext as __vite__createHotContext } from "/@vite/client";import.meta.hot = __vite__createHotContext("/src/pages/index.tsx");import __vite__cjsImport0_react_jsxDevRuntime from "/node_modules/.vite/deps/react_jsx-dev-runtime.js?v=38c95354"; const Fragment = __vite__cjsImport0_react_jsxDevRuntime["Fragment"]; const jsxDEV = __vite__cjsImport0_react_jsxDevRuntime["jsxDEV"];
import * as RefreshRuntime from "/@react-refresh";
const inWebWorker = typeof WorkerGlobalScope !== "undefined" && self instanceof WorkerGlobalScope;
let prevRefreshReg;
let prevRefreshSig;
if (import.meta.hot && !inWebWorker) {
  if (!window.$RefreshReg$) {
    throw new Error(
      "@vitejs/plugin-react can't detect preamble. Something is wrong."
    );
  }
  prevRefreshReg = window.$RefreshReg$;
  prevRefreshSig = window.$RefreshSig$;
  window.$RefreshReg$ = RefreshRuntime.getRefreshReg("/app/src/pages/index.tsx");
  window.$RefreshSig$ = RefreshRuntime.createSignatureFunctionForTransform;
}
var _s = $RefreshSig$(), _s2 = $RefreshSig$();
import { FormattedBoundText } from "/src/components/FormattedBoundText.tsx";
import __vite__cjsImport4_react from "/node_modules/.vite/deps/react.js?v=38c95354"; const useRef = __vite__cjsImport4_react["useRef"]; const useState = __vite__cjsImport4_react["useState"];
import { Helmet } from "/node_modules/.vite/deps/@dr__pogodin_react-helmet.js?v=38c95354";
import { motion, useInView } from "/node_modules/.vite/deps/motion_react.js?v=38c95354";
import { home } from "/@id/__x00__virtual:content";
function EmberParticles() {
  _s();
  const [particles] = useState(
    () => Array.from({ length: 28 }, (_, i) => ({
      id: i,
      x: Math.random() * 100,
      y: Math.random() * 100,
      size: Math.random() * 3 + 1,
      duration: Math.random() * 8 + 6,
      delay: Math.random() * 6,
      drift: (Math.random() - 0.5) * 60
    }))
  );
  return /* @__PURE__ */ jsxDEV("div", { className: "absolute inset-0 overflow-hidden pointer-events-none", "aria-hidden": "true", "data-dev-dynamic": "true", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 31, "data-dev-id": "a2cc50", children: particles.map(
    (p) => /* @__PURE__ */ jsxDEV(
      motion.div,
      {
        className: "absolute rounded-full",
        style: {
          left: `${p.x}%`,
          top: `${p.y}%`,
          width: p.size,
          height: p.size,
          background: p.size > 3 ? "#ff7a26" : "#e8451c",
          boxShadow: `0 0 ${p.size * 3}px ${p.size > 3 ? "#ff7a26" : "#e8451c"}`
        },
        animate: {
          y: [0, -120, -200],
          x: [0, p.drift],
          opacity: [0, 0.8, 0],
          scale: [0.5, 1, 0.2]
        },
        transition: {
          duration: p.duration,
          delay: p.delay,
          repeat: Infinity,
          ease: "easeOut"
        },
        "data-dev-file": "/app/src/pages/index.tsx",
        "data-dev-line": 33,
        "data-dev-id": "35e7a8"
      },
      p.id,
      false,
      {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 52,
        columnNumber: 7
      },
      this
    )
  ) }, void 0, false, {
    fileName: "/app/src/pages/index.tsx",
    lineNumber: 50,
    columnNumber: 5
  }, this);
}
_s(EmberParticles, "mczxntE+4gppuSdqnezQOP9YUCg=");
_c = EmberParticles;
function FadeIn({
  children,
  delay = 0,
  className = ""
}) {
  _s2();
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });
  return /* @__PURE__ */ jsxDEV(
    motion.div,
    {
      ref,
      className,
      initial: { opacity: 0, y: 32 },
      animate: inView ? { opacity: 1, y: 0 } : {},
      transition: { duration: 0.7, delay, ease: "easeOut" },
      "data-dev-file": "/app/src/pages/index.tsx",
      "data-dev-line": 76,
      "data-dev-id": "980a54",
      children
    },
    void 0,
    false,
    {
      fileName: "/app/src/pages/index.tsx",
      lineNumber: 95,
      columnNumber: 5
    },
    this
  );
}
_s2(FadeIn, "O7qYEn3iCrBBWRAefWku+E/MdDM=", false, function() {
  return [useInView];
});
_c2 = FadeIn;
function LavaDivider() {
  return /* @__PURE__ */ jsxDEV("div", { className: "relative w-full overflow-hidden", style: { height: "3px" }, "aria-hidden": "true", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 91, "data-dev-id": "a2cc50", children: [
    /* @__PURE__ */ jsxDEV(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "linear-gradient(90deg, transparent 0%, #e8451c 20%, #ff7a26 50%, #e8451c 80%, transparent 100%)",
          opacity: 0.5
        },
        "data-dev-file": "/app/src/pages/index.tsx",
        "data-dev-line": 92,
        "data-dev-id": "abc024"
      },
      void 0,
      false,
      {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 111,
        columnNumber: 7
      },
      this
    ),
    /* @__PURE__ */ jsxDEV(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "linear-gradient(90deg, transparent 0%, rgba(255,122,38,0.3) 30%, rgba(255,122,38,0.6) 50%, rgba(255,122,38,0.3) 70%, transparent 100%)",
          filter: "blur(4px)"
        },
        "data-dev-file": "/app/src/pages/index.tsx",
        "data-dev-line": 101,
        "data-dev-id": "abc025"
      },
      void 0,
      false,
      {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 120,
        columnNumber: 7
      },
      this
    )
  ] }, void 0, true, {
    fileName: "/app/src/pages/index.tsx",
    lineNumber: 110,
    columnNumber: 5
  }, this);
}
_c3 = LavaDivider;
export default function HomePage() {
  const site = "https://wpaistudio.net";
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "WebSite",
        "@id": `${site}/#website`,
        name: "Wizard Productions AI Studio",
        url: `${site}/`
      },
      {
        "@type": "Organization",
        "@id": `${site}/#organization`,
        name: "Wizard Productions AI Studio",
        url: `${site}/`,
        founder: { "@type": "Person", name: "Rob Bulkley" },
        sameAs: [
          "https://wpaistudio.gumroad.com",
          "https://github.com/MrWizard94-Compile"
        ]
      },
      {
        "@type": "WebPage",
        "@id": `${site}/#webpage`,
        url: `${site}/`,
        name: "Wizard Productions AI Studio — Forging the future of creative media",
        isPartOf: { "@id": `${site}/#website` },
        about: { "@id": `${site}/#organization` },
        datePublished: "2026-07-10",
        dateModified: "2026-07-10"
      }
    ]
  };
  return /* @__PURE__ */ jsxDEV(Fragment, { children: [
    /* @__PURE__ */ jsxDEV(Helmet, { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 153, "data-dev-id": "556fec", children: [
      /* @__PURE__ */ jsxDEV("title", { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 154, "data-dev-id": "bf619f", children: "Wizard Productions AI Studio — Forging the future of creative media" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 173,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV(
        "meta",
        {
          name: "description",
          content: "WPAI: AI creative studio shipping heavy music, developer tools, games, and AI research. Human-directed, AI-assisted. RepoForge Pro, The Mixin Field Manual, and more.",
          "data-dev-file": "/app/src/pages/index.tsx",
          "data-dev-line": 155,
          "data-dev-id": "f4b9e4"
        },
        void 0,
        false,
        {
          fileName: "/app/src/pages/index.tsx",
          lineNumber: 174,
          columnNumber: 9
        },
        this
      ),
      /* @__PURE__ */ jsxDEV("link", { rel: "canonical", href: site, "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 159, "data-dev-id": "e4d38b" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 178,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV("meta", { property: "og:title", content: "Wizard Productions AI Studio", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 160, "data-dev-id": "f4b9e5" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 179,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV(
        "meta",
        {
          property: "og:description",
          content: "AI is in the name. The wizard is in the work. Heavy music, developer tools, games, and deep research — forged under one brand.",
          "data-dev-file": "/app/src/pages/index.tsx",
          "data-dev-line": 161,
          "data-dev-id": "f4b9e6"
        },
        void 0,
        false,
        {
          fileName: "/app/src/pages/index.tsx",
          lineNumber: 180,
          columnNumber: 9
        },
        this
      ),
      /* @__PURE__ */ jsxDEV("meta", { property: "og:type", content: "website", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 165, "data-dev-id": "f4b9e7" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 184,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV("meta", { property: "og:url", content: site, "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 166, "data-dev-id": "f4b9e8" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 185,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV("meta", { name: "twitter:card", content: "summary_large_image", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 167, "data-dev-id": "f4b9e9" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 186,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV("meta", { name: "twitter:title", content: "Wizard Productions AI Studio", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 168, "data-dev-id": "f4b9ea" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 187,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV(
        "meta",
        {
          name: "twitter:description",
          content: "AI is in the name. The wizard is in the work.",
          "data-dev-file": "/app/src/pages/index.tsx",
          "data-dev-line": 169,
          "data-dev-id": "f4b9eb"
        },
        void 0,
        false,
        {
          fileName: "/app/src/pages/index.tsx",
          lineNumber: 188,
          columnNumber: 9
        },
        this
      ),
      /* @__PURE__ */ jsxDEV("script", { type: "application/ld+json", "data-dev-dynamic": "true", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 173, "data-dev-id": "b31892", children: JSON.stringify(jsonLd) }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 192,
        columnNumber: 9
      }, this)
    ] }, void 0, true, {
      fileName: "/app/src/pages/index.tsx",
      lineNumber: 172,
      columnNumber: 7
    }, this),
    /* @__PURE__ */ jsxDEV("main", { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 176, "data-dev-id": "641c92", children: [
      /* @__PURE__ */ jsxDEV(
        "section",
        {
          id: "hero",
          className: "relative overflow-hidden",
          style: {
            background: "linear-gradient(180deg, #0a0706 0%, #12100e 60%, #0a0706 100%)",
            minHeight: "100vh",
            display: "flex",
            alignItems: "center"
          },
          "data-dev-file": "/app/src/pages/index.tsx",
          "data-dev-line": 178,
          "data-dev-id": "8c0c78",
          children: [
            /* @__PURE__ */ jsxDEV(
              "div",
              {
                className: "absolute inset-0 pointer-events-none",
                "aria-hidden": "true",
                style: { opacity: 0.18 },
                "data-dev-file": "/app/src/pages/index.tsx",
                "data-dev-line": 189,
                "data-dev-id": "9e7e4c",
                children: /* @__PURE__ */ jsxDEV(
                  "img",
                  {
                    src: "/airo-assets/images/pages/home/hero-forge",
                    alt: "",
                    className: "w-full h-full object-cover",
                    loading: "eager",
                    fetchPriority: "high",
                    width: 1920,
                    height: 1080,
                    "data-dev-file": "/app/src/pages/index.tsx",
                    "data-dev-line": 194,
                    "data-dev-id": "986b5a"
                  },
                  void 0,
                  false,
                  {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 213,
                    columnNumber: 13
                  },
                  this
                )
              },
              void 0,
              false,
              {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 208,
                columnNumber: 11
              },
              this
            ),
            /* @__PURE__ */ jsxDEV(
              "div",
              {
                className: "absolute inset-0 pointer-events-none",
                "aria-hidden": "true",
                style: {
                  background: "radial-gradient(ellipse 70% 60% at 50% 60%, rgba(232,69,28,0.12) 0%, transparent 70%)"
                },
                "data-dev-file": "/app/src/pages/index.tsx",
                "data-dev-line": 206,
                "data-dev-id": "9e7e4d"
              },
              void 0,
              false,
              {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 225,
                columnNumber: 11
              },
              this
            ),
            /* @__PURE__ */ jsxDEV(EmberParticles, { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 215, "data-dev-id": "a14f7b" }, void 0, false, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 234,
              columnNumber: 11
            }, this),
            /* @__PURE__ */ jsxDEV("div", { className: "container mx-auto px-6 py-24 relative z-10", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 217, "data-dev-id": "9e7e4e", children: /* @__PURE__ */ jsxDEV("div", { className: "max-w-4xl", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 218, "data-dev-id": "3078a2", children: [
              /* @__PURE__ */ jsxDEV(
                motion.div,
                {
                  initial: { opacity: 0, y: -12 },
                  animate: { opacity: 1, y: 0 },
                  transition: { duration: 0.6, ease: "easeOut" },
                  className: "inline-flex items-center mb-8",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 220,
                  "data-dev-id": "2d893a",
                  children: /* @__PURE__ */ jsxDEV(
                    "span",
                    {
                      className: "text-xs font-semibold px-4 py-2 tracking-widest uppercase",
                      style: {
                        border: "1px solid rgba(255, 122, 38, 0.4)",
                        color: "#ff7a26",
                        background: "rgba(255, 122, 38, 0.06)",
                        letterSpacing: "0.18em",
                        fontFamily: "var(--font-sans)"
                      },
                      "data-dev-content-key": "home.hero.badge",
                      "data-dev-bound-text": "true",
                      "data-dev-bound-source-kind": "content-key",
                      "data-dev-file": "/app/src/pages/index.tsx",
                      "data-dev-line": 226,
                      "data-dev-id": "615cdd",
                      children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "615cdd", guard: { file: "src/pages/index.tsx", tagName: "span", sourceKind: "content-key", contentKey: "home.hero.badge", contentKeyTemplate: null, expressionHash: null }, children: home.hero.badge }, void 0, false, {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 255,
                        columnNumber: 19
                      }, this)
                    },
                    void 0,
                    false,
                    {
                      fileName: "/app/src/pages/index.tsx",
                      lineNumber: 245,
                      columnNumber: 17
                    },
                    this
                  )
                },
                void 0,
                false,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 239,
                  columnNumber: 15
                },
                this
              ),
              /* @__PURE__ */ jsxDEV(
                motion.h1,
                {
                  initial: { opacity: 0, y: 24 },
                  animate: { opacity: 1, y: 0 },
                  transition: { duration: 0.8, delay: 0.1, ease: "easeOut" },
                  className: "mb-6 leading-tight",
                  style: {
                    fontFamily: "var(--font-heading)",
                    fontSize: "clamp(2.8rem, 7vw, 5.5rem)",
                    fontWeight: 900,
                    color: "#f5ede4",
                    lineHeight: 1.05
                  },
                  "data-dev-editable": "text",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 241,
                  "data-dev-id": "bcc870",
                  children: [
                    /* @__PURE__ */ jsxDEV("span", { "data-dev-content-key": "home.hero.headline_start", "data-dev-bound-text": "true", "data-dev-bound-source-kind": "content-key", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 254, "data-dev-id": "56a353", children: [
                      /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "56a353", guard: { file: "src/pages/index.tsx", tagName: "span", sourceKind: "content-key", contentKey: "home.hero.headline_start", contentKeyTemplate: null, expressionHash: null }, children: home.hero.headline_start }, void 0, false, {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 273,
                        columnNumber: 221
                      }, this),
                      " "
                    ] }, void 0, true, {
                      fileName: "/app/src/pages/index.tsx",
                      lineNumber: 273,
                      columnNumber: 17
                    }, this),
                    /* @__PURE__ */ jsxDEV(
                      "span",
                      {
                        style: {
                          color: "#ff7a26",
                          textShadow: "0 0 40px rgba(255, 122, 38, 0.5)"
                        },
                        "data-dev-content-key": "home.hero.headline_accent",
                        "data-dev-bound-text": "true",
                        "data-dev-bound-source-kind": "content-key",
                        "data-dev-file": "/app/src/pages/index.tsx",
                        "data-dev-line": 255,
                        "data-dev-id": "56a354",
                        children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "56a354", guard: { file: "src/pages/index.tsx", tagName: "span", sourceKind: "content-key", contentKey: "home.hero.headline_accent", contentKeyTemplate: null, expressionHash: null }, children: home.hero.headline_accent }, void 0, false, {
                          fileName: "/app/src/pages/index.tsx",
                          lineNumber: 280,
                          columnNumber: 19
                        }, this)
                      },
                      void 0,
                      false,
                      {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 274,
                        columnNumber: 17
                      },
                      this
                    )
                  ]
                },
                void 0,
                true,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 260,
                  columnNumber: 15
                },
                this
              ),
              /* @__PURE__ */ jsxDEV(
                motion.p,
                {
                  initial: { opacity: 0, y: 20 },
                  animate: { opacity: 1, y: 0 },
                  transition: { duration: 0.8, delay: 0.25, ease: "easeOut" },
                  className: "mb-8 max-w-2xl leading-relaxed",
                  style: {
                    fontFamily: "var(--font-sans)",
                    fontSize: "clamp(1rem, 2vw, 1.2rem)",
                    color: "rgba(245, 237, 228, 0.7)"
                  },
                  "data-dev-content-key": "home.hero.lede",
                  "data-dev-bound-text": "true",
                  "data-dev-bound-source-kind": "content-key",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 266,
                  "data-dev-id": "24e087",
                  children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "24e087", guard: { file: "src/pages/index.tsx", tagName: "p", sourceKind: "content-key", contentKey: "home.hero.lede", contentKeyTemplate: null, expressionHash: null }, children: home.hero.lede }, void 0, false, {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 296,
                    columnNumber: 17
                  }, this)
                },
                void 0,
                false,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 285,
                  columnNumber: 15
                },
                this
              ),
              /* @__PURE__ */ jsxDEV(
                motion.p,
                {
                  initial: { opacity: 0 },
                  animate: { opacity: 1 },
                  transition: { duration: 1, delay: 0.4 },
                  className: "mb-10 italic",
                  style: {
                    fontFamily: "var(--font-heading)",
                    fontSize: "clamp(1.1rem, 2.5vw, 1.5rem)",
                    color: "rgba(245, 237, 228, 0.5)",
                    letterSpacing: "0.02em"
                  },
                  "data-dev-editable": "text",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 281,
                  "data-dev-id": "24e088",
                  children: [
                    '"',
                    /* @__PURE__ */ jsxDEV("span", { "data-dev-content-key": "home.hero.thesis", "data-dev-bound-text": "true", "data-dev-bound-source-kind": "content-key", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 293, "data-dev-id": "dfb06b", children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "dfb06b", guard: { file: "src/pages/index.tsx", tagName: "span", sourceKind: "content-key", contentKey: "home.hero.thesis", contentKeyTemplate: null, expressionHash: null }, children: home.hero.thesis }, void 0, false, {
                      fileName: "/app/src/pages/index.tsx",
                      lineNumber: 312,
                      columnNumber: 214
                    }, this) }, void 0, false, {
                      fileName: "/app/src/pages/index.tsx",
                      lineNumber: 312,
                      columnNumber: 18
                    }, this),
                    '"'
                  ]
                },
                void 0,
                true,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 300,
                  columnNumber: 15
                },
                this
              ),
              /* @__PURE__ */ jsxDEV(
                motion.div,
                {
                  initial: { opacity: 0, y: 16 },
                  animate: { opacity: 1, y: 0 },
                  transition: { duration: 0.7, delay: 0.5, ease: "easeOut" },
                  className: "flex flex-wrap gap-4",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 297,
                  "data-dev-id": "2d893b",
                  children: [
                    /* @__PURE__ */ jsxDEV(
                      motion.a,
                      {
                        href: home.hero.cta_primary_url,
                        target: "_blank",
                        rel: "noopener noreferrer",
                        className: "inline-flex items-center gap-2 px-8 py-4 font-semibold text-white transition-all duration-200",
                        style: {
                          background: "linear-gradient(135deg, #ff7a26, #e8451c)",
                          borderRadius: "2px",
                          fontSize: "0.95rem",
                          letterSpacing: "0.06em",
                          fontFamily: "var(--font-sans)",
                          boxShadow: "0 0 24px rgba(255, 122, 38, 0.4)"
                        },
                        whileHover: {
                          boxShadow: "0 0 48px rgba(255, 122, 38, 0.7)",
                          scale: 1.02
                        },
                        whileTap: { scale: 0.98 },
                        "data-dev-content-key": "home.hero.cta_primary",
                        "data-dev-bound-text": "true",
                        "data-dev-bound-source-kind": "content-key",
                        "data-dev-file": "/app/src/pages/index.tsx",
                        "data-dev-line": 303,
                        "data-dev-id": "4a7fb1",
                        children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "4a7fb1", guard: { file: "src/pages/index.tsx", tagName: "a", sourceKind: "content-key", contentKey: "home.hero.cta_primary", contentKeyTemplate: null, expressionHash: null }, children: home.hero.cta_primary }, void 0, false, {
                          fileName: "/app/src/pages/index.tsx",
                          lineNumber: 341,
                          columnNumber: 19
                        }, this)
                      },
                      void 0,
                      false,
                      {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 322,
                        columnNumber: 17
                      },
                      this
                    ),
                    /* @__PURE__ */ jsxDEV(
                      motion.button,
                      {
                        onClick: () => {
                          document.querySelector("#products")?.scrollIntoView({ behavior: "smooth" });
                        },
                        className: "inline-flex items-center gap-2 px-8 py-4 font-semibold transition-all duration-200 cursor-pointer",
                        style: {
                          border: "1px solid rgba(255, 122, 38, 0.4)",
                          color: "rgba(245, 237, 228, 0.85)",
                          borderRadius: "2px",
                          fontSize: "0.95rem",
                          letterSpacing: "0.06em",
                          fontFamily: "var(--font-sans)",
                          background: "transparent"
                        },
                        whileHover: {
                          borderColor: "rgba(255, 122, 38, 0.8)",
                          color: "#ff7a26"
                        },
                        whileTap: { scale: 0.98 },
                        "data-dev-content-key": "home.hero.cta_secondary",
                        "data-dev-bound-text": "true",
                        "data-dev-bound-source-kind": "content-key",
                        "data-dev-file": "/app/src/pages/index.tsx",
                        "data-dev-line": 325,
                        "data-dev-id": "0cdcec",
                        children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "0cdcec", guard: { file: "src/pages/index.tsx", tagName: "button", sourceKind: "content-key", contentKey: "home.hero.cta_secondary", contentKeyTemplate: null, expressionHash: null }, children: home.hero.cta_secondary }, void 0, false, {
                          fileName: "/app/src/pages/index.tsx",
                          lineNumber: 364,
                          columnNumber: 19
                        }, this)
                      },
                      void 0,
                      false,
                      {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 344,
                        columnNumber: 17
                      },
                      this
                    )
                  ]
                },
                void 0,
                true,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 316,
                  columnNumber: 15
                },
                this
              )
            ] }, void 0, true, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 237,
              columnNumber: 13
            }, this) }, void 0, false, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 236,
              columnNumber: 11
            }, this),
            /* @__PURE__ */ jsxDEV(
              "div",
              {
                className: "absolute bottom-0 left-0 right-0 pointer-events-none",
                "aria-hidden": "true",
                style: {
                  height: "120px",
                  background: "linear-gradient(to bottom, transparent, #0a0706)"
                },
                "data-dev-file": "/app/src/pages/index.tsx",
                "data-dev-line": 352,
                "data-dev-id": "9e7e4f"
              },
              void 0,
              false,
              {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 371,
                columnNumber: 11
              },
              this
            )
          ]
        },
        void 0,
        true,
        {
          fileName: "/app/src/pages/index.tsx",
          lineNumber: 197,
          columnNumber: 9
        },
        this
      ),
      /* @__PURE__ */ jsxDEV(LavaDivider, { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 362, "data-dev-id": "78446e" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 381,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV(
        "section",
        {
          id: "products",
          className: "relative py-24 overflow-hidden",
          style: { background: "#0a0706" },
          "data-dev-file": "/app/src/pages/index.tsx",
          "data-dev-line": 365,
          "data-dev-id": "8c0c79",
          children: [
            /* @__PURE__ */ jsxDEV(
              "div",
              {
                className: "absolute inset-0 pointer-events-none",
                "aria-hidden": "true",
                style: { opacity: 0.07 },
                "data-dev-file": "/app/src/pages/index.tsx",
                "data-dev-line": 371,
                "data-dev-id": "98bb0d",
                children: /* @__PURE__ */ jsxDEV(
                  "img",
                  {
                    src: "/airo-assets/images/pages/home/products-bg",
                    alt: "",
                    className: "w-full h-full object-cover",
                    loading: "lazy",
                    width: 1920,
                    height: 1080,
                    "data-dev-file": "/app/src/pages/index.tsx",
                    "data-dev-line": 376,
                    "data-dev-id": "f774db"
                  },
                  void 0,
                  false,
                  {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 395,
                    columnNumber: 13
                  },
                  this
                )
              },
              void 0,
              false,
              {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 390,
                columnNumber: 11
              },
              this
            ),
            /* @__PURE__ */ jsxDEV("div", { className: "container mx-auto px-6 relative z-10", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 386, "data-dev-id": "98bb0e", children: [
              /* @__PURE__ */ jsxDEV(FadeIn, { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 387, "data-dev-id": "b50dc6", children: /* @__PURE__ */ jsxDEV("div", { className: "mb-14", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 388, "data-dev-id": "02c21a", children: [
                /* @__PURE__ */ jsxDEV(
                  "span",
                  {
                    className: "text-xs uppercase tracking-widest mb-3 block",
                    style: { color: "#ff7a26", fontFamily: "var(--font-sans)", letterSpacing: "0.2em" },
                    "data-dev-content-key": "home.products.section_label",
                    "data-dev-bound-text": "true",
                    "data-dev-bound-source-kind": "content-key",
                    "data-dev-file": "/app/src/pages/index.tsx",
                    "data-dev-line": 389,
                    "data-dev-id": "c1d9bd",
                    children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "c1d9bd", guard: { file: "src/pages/index.tsx", tagName: "span", sourceKind: "content-key", contentKey: "home.products.section_label", contentKeyTemplate: null, expressionHash: null }, children: home.products.section_label }, void 0, false, {
                      fileName: "/app/src/pages/index.tsx",
                      lineNumber: 412,
                      columnNumber: 19
                    }, this)
                  },
                  void 0,
                  false,
                  {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 408,
                    columnNumber: 17
                  },
                  this
                ),
                /* @__PURE__ */ jsxDEV(
                  "h2",
                  {
                    style: {
                      fontFamily: "var(--font-heading)",
                      fontSize: "clamp(2rem, 4vw, 3rem)",
                      fontWeight: 700,
                      color: "#f5ede4"
                    },
                    "data-dev-editable": "text",
                    "data-dev-file": "/app/src/pages/index.tsx",
                    "data-dev-line": 395,
                    "data-dev-id": "4df265",
                    children: "Forged. Shipped. For sale."
                  },
                  void 0,
                  false,
                  {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 414,
                    columnNumber: 17
                  },
                  this
                )
              ] }, void 0, true, {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 407,
                columnNumber: 15
              }, this) }, void 0, false, {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 406,
                columnNumber: 13
              }, this),
              /* @__PURE__ */ jsxDEV("div", { className: "grid grid-cols-1 lg:grid-cols-2 gap-8", "data-dev-dynamic": "true", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 408, "data-dev-id": "954562", children: home.products.items.map(
                (item, i) => /* @__PURE__ */ jsxDEV(FadeIn, { delay: i * 0.15, "data-dev-content-list": "home.products.items", "data-dev-content-list-index": i, "data-dev-item-id": item.id, "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 410, "data-dev-id": "e4769a", children: /* @__PURE__ */ jsxDEV(
                  "div",
                  {
                    className: "relative p-8 h-full flex flex-col transition-all duration-300 group",
                    style: {
                      background: "linear-gradient(135deg, #12100e 0%, #0f0d0b 100%)",
                      border: "1px solid rgba(255, 122, 38, 0.15)",
                      borderRadius: "2px"
                    },
                    onMouseEnter: (e) => {
                      e.currentTarget.style.borderColor = "rgba(255, 122, 38, 0.45)";
                      e.currentTarget.style.boxShadow = "0 0 40px rgba(255, 122, 38, 0.1), inset 0 0 40px rgba(255, 122, 38, 0.03)";
                    },
                    onMouseLeave: (e) => {
                      e.currentTarget.style.borderColor = "rgba(255, 122, 38, 0.15)";
                      e.currentTarget.style.boxShadow = "none";
                    },
                    "data-dev-file": "/app/src/pages/index.tsx",
                    "data-dev-line": 411,
                    "data-dev-id": "5a79ee",
                    children: [
                      /* @__PURE__ */ jsxDEV("div", { className: "flex items-center justify-between mb-6", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 428, "data-dev-id": "22ac42", children: [
                        /* @__PURE__ */ jsxDEV(
                          "span",
                          {
                            className: "text-xs uppercase tracking-widest px-3 py-1",
                            style: {
                              color: "#ff7a26",
                              border: "1px solid rgba(255, 122, 38, 0.3)",
                              fontFamily: "var(--font-sans)",
                              letterSpacing: "0.15em"
                            },
                            "data-dev-content-key-template": "home.products.items[].category",
                            "data-dev-file": "/app/src/pages/index.tsx",
                            "data-dev-line": 429,
                            "data-dev-id": "dfc6e5",
                            children: item.category
                          },
                          void 0,
                          false,
                          {
                            fileName: "/app/src/pages/index.tsx",
                            lineNumber: 448,
                            columnNumber: 23
                          },
                          this
                        ),
                        /* @__PURE__ */ jsxDEV(
                          "span",
                          {
                            style: {
                              fontFamily: "var(--font-heading)",
                              fontSize: "1.8rem",
                              fontWeight: 700,
                              color: "#ff7a26",
                              textShadow: "0 0 20px rgba(255, 122, 38, 0.4)"
                            },
                            "data-dev-content-key-template": "home.products.items[].price",
                            "data-dev-file": "/app/src/pages/index.tsx",
                            "data-dev-line": 440,
                            "data-dev-id": "dfc6e6",
                            children: item.price
                          },
                          void 0,
                          false,
                          {
                            fileName: "/app/src/pages/index.tsx",
                            lineNumber: 459,
                            columnNumber: 23
                          },
                          this
                        )
                      ] }, void 0, true, {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 447,
                        columnNumber: 21
                      }, this),
                      /* @__PURE__ */ jsxDEV(
                        "h3",
                        {
                          className: "mb-4",
                          style: {
                            fontFamily: "var(--font-heading)",
                            fontSize: "clamp(1.4rem, 2.5vw, 1.9rem)",
                            fontWeight: 700,
                            color: "#f5ede4",
                            lineHeight: 1.2
                          },
                          "data-dev-content-key-template": "home.products.items[].name",
                          "data-dev-file": "/app/src/pages/index.tsx",
                          "data-dev-line": 454,
                          "data-dev-id": "95b2fa",
                          children: item.name
                        },
                        void 0,
                        false,
                        {
                          fileName: "/app/src/pages/index.tsx",
                          lineNumber: 473,
                          columnNumber: 21
                        },
                        this
                      ),
                      /* @__PURE__ */ jsxDEV(
                        "p",
                        {
                          className: "mb-8 flex-1 leading-relaxed",
                          style: {
                            fontFamily: "var(--font-sans)",
                            fontSize: "0.95rem",
                            color: "rgba(245, 237, 228, 0.6)",
                            lineHeight: 1.7
                          },
                          "data-dev-content-key-template": "home.products.items[].description",
                          "data-dev-file": "/app/src/pages/index.tsx",
                          "data-dev-line": 468,
                          "data-dev-id": "e5a18f",
                          children: item.description
                        },
                        void 0,
                        false,
                        {
                          fileName: "/app/src/pages/index.tsx",
                          lineNumber: 487,
                          columnNumber: 21
                        },
                        this
                      ),
                      /* @__PURE__ */ jsxDEV("div", { className: "flex flex-wrap gap-3", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 481, "data-dev-id": "22ac43", children: [
                        /* @__PURE__ */ jsxDEV(
                          "a",
                          {
                            href: item.buy_url,
                            target: "_blank",
                            rel: "noopener noreferrer",
                            className: "inline-flex items-center px-6 py-3 font-semibold text-white transition-all duration-200",
                            style: {
                              background: "linear-gradient(135deg, #ff7a26, #e8451c)",
                              borderRadius: "2px",
                              fontSize: "0.875rem",
                              letterSpacing: "0.05em",
                              fontFamily: "var(--font-sans)",
                              boxShadow: "0 0 16px rgba(255, 122, 38, 0.25)"
                            },
                            onMouseEnter: (e) => {
                              e.currentTarget.style.boxShadow = "0 0 32px rgba(255, 122, 38, 0.5)";
                            },
                            onMouseLeave: (e) => {
                              e.currentTarget.style.boxShadow = "0 0 16px rgba(255, 122, 38, 0.25)";
                            },
                            "data-dev-content-key-template": "home.products.items[].buy_label",
                            "data-dev-file": "/app/src/pages/index.tsx",
                            "data-dev-line": 482,
                            "data-dev-id": "78b695",
                            children: item.buy_label
                          },
                          void 0,
                          false,
                          {
                            fileName: "/app/src/pages/index.tsx",
                            lineNumber: 501,
                            columnNumber: 23
                          },
                          this
                        ),
                        /* @__PURE__ */ jsxDEV(
                          "a",
                          {
                            href: item.free_url,
                            target: "_blank",
                            rel: "noopener noreferrer",
                            className: "inline-flex items-center px-6 py-3 font-medium transition-all duration-200",
                            style: {
                              border: "1px solid rgba(255, 122, 38, 0.25)",
                              color: "rgba(245, 237, 228, 0.6)",
                              borderRadius: "2px",
                              fontSize: "0.875rem",
                              letterSpacing: "0.05em",
                              fontFamily: "var(--font-sans)"
                            },
                            onMouseEnter: (e) => {
                              e.currentTarget.style.color = "#ff7a26";
                              e.currentTarget.style.borderColor = "rgba(255, 122, 38, 0.5)";
                            },
                            onMouseLeave: (e) => {
                              e.currentTarget.style.color = "rgba(245, 237, 228, 0.6)";
                              e.currentTarget.style.borderColor = "rgba(255, 122, 38, 0.25)";
                            },
                            "data-dev-content-key-template": "home.products.items[].free_label",
                            "data-dev-file": "/app/src/pages/index.tsx",
                            "data-dev-line": 504,
                            "data-dev-id": "78b696",
                            children: item.free_label
                          },
                          void 0,
                          false,
                          {
                            fileName: "/app/src/pages/index.tsx",
                            lineNumber: 523,
                            columnNumber: 23
                          },
                          this
                        )
                      ] }, void 0, true, {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 500,
                        columnNumber: 21
                      }, this)
                    ]
                  },
                  void 0,
                  true,
                  {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 430,
                    columnNumber: 19
                  },
                  this
                ) }, item.id, false, {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 429,
                  columnNumber: 15
                }, this)
              ) }, void 0, false, {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 427,
                columnNumber: 13
              }, this)
            ] }, void 0, true, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 405,
              columnNumber: 11
            }, this)
          ]
        },
        void 0,
        true,
        {
          fileName: "/app/src/pages/index.tsx",
          lineNumber: 384,
          columnNumber: 9
        },
        this
      ),
      /* @__PURE__ */ jsxDEV(LavaDivider, { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 536, "data-dev-id": "78446f" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 555,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV(
        "section",
        {
          id: "studio",
          className: "relative py-24",
          style: { background: "#12100e" },
          "data-dev-file": "/app/src/pages/index.tsx",
          "data-dev-line": 539,
          "data-dev-id": "8c0c7a",
          children: /* @__PURE__ */ jsxDEV("div", { className: "container mx-auto px-6", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 544, "data-dev-id": "92f7ce", children: [
            /* @__PURE__ */ jsxDEV(FadeIn, { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 545, "data-dev-id": "dfa286", children: /* @__PURE__ */ jsxDEV("div", { className: "mb-14", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 546, "data-dev-id": "79e6da", children: [
              /* @__PURE__ */ jsxDEV(
                "span",
                {
                  className: "text-xs uppercase tracking-widest mb-3 block",
                  style: { color: "#ff7a26", fontFamily: "var(--font-sans)", letterSpacing: "0.2em" },
                  "data-dev-content-key": "home.studio.section_label",
                  "data-dev-bound-text": "true",
                  "data-dev-bound-source-kind": "content-key",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 547,
                  "data-dev-id": "a8267d",
                  children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "a8267d", guard: { file: "src/pages/index.tsx", tagName: "span", sourceKind: "content-key", contentKey: "home.studio.section_label", contentKeyTemplate: null, expressionHash: null }, children: home.studio.section_label }, void 0, false, {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 570,
                    columnNumber: 19
                  }, this)
                },
                void 0,
                false,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 566,
                  columnNumber: 17
                },
                this
              ),
              /* @__PURE__ */ jsxDEV(
                "h2",
                {
                  style: {
                    fontFamily: "var(--font-heading)",
                    fontSize: "clamp(2rem, 4vw, 3rem)",
                    fontWeight: 700,
                    color: "#f5ede4"
                  },
                  "data-dev-content-key": "home.studio.headline",
                  "data-dev-bound-text": "true",
                  "data-dev-bound-source-kind": "content-key",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 553,
                  "data-dev-id": "ba0f25",
                  children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "ba0f25", guard: { file: "src/pages/index.tsx", tagName: "h2", sourceKind: "content-key", contentKey: "home.studio.headline", contentKeyTemplate: null, expressionHash: null }, children: home.studio.headline }, void 0, false, {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 580,
                    columnNumber: 19
                  }, this)
                },
                void 0,
                false,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 572,
                  columnNumber: 17
                },
                this
              )
            ] }, void 0, true, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 565,
              columnNumber: 15
            }, this) }, void 0, false, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 564,
              columnNumber: 13
            }, this),
            /* @__PURE__ */ jsxDEV("div", { className: "grid grid-cols-1 md:grid-cols-3 gap-0", "data-dev-dynamic": "true", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 566, "data-dev-id": "fa1222", children: home.studio.lanes.map(
              (lane, i) => /* @__PURE__ */ jsxDEV(FadeIn, { delay: i * 0.12, "data-dev-content-list": "home.studio.lanes", "data-dev-content-list-index": i, "data-dev-item-id": lane.id, "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 568, "data-dev-id": "5b9b5a", children: /* @__PURE__ */ jsxDEV(
                "div",
                {
                  className: "relative p-8 h-full transition-all duration-300",
                  style: {
                    borderLeft: i === 0 ? "2px solid rgba(255, 122, 38, 0.3)" : "1px solid rgba(255, 122, 38, 0.1)",
                    borderRight: i === 2 ? "2px solid rgba(255, 122, 38, 0.3)" : "none"
                  },
                  onMouseEnter: (e) => {
                    e.currentTarget.style.background = "rgba(255, 122, 38, 0.04)";
                  },
                  onMouseLeave: (e) => {
                    e.currentTarget.style.background = "transparent";
                  },
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 569,
                  "data-dev-id": "4a2eae",
                  children: [
                    /* @__PURE__ */ jsxDEV(
                      "div",
                      {
                        className: "text-6xl font-black mb-4 select-none",
                        style: {
                          fontFamily: "var(--font-heading)",
                          color: "rgba(255, 122, 38, 0.08)",
                          lineHeight: 1
                        },
                        "data-dev-dynamic": "true",
                        "data-dev-file": "/app/src/pages/index.tsx",
                        "data-dev-line": 583,
                        "data-dev-id": "b6f102",
                        children: [
                          "0",
                          i + 1
                        ]
                      },
                      void 0,
                      true,
                      {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 602,
                        columnNumber: 21
                      },
                      this
                    ),
                    /* @__PURE__ */ jsxDEV(
                      "h3",
                      {
                        className: "mb-3",
                        style: {
                          fontFamily: "var(--font-heading)",
                          fontSize: "1.5rem",
                          fontWeight: 700,
                          color: "#f5ede4"
                        },
                        "data-dev-content-key-template": "home.studio.lanes[].name",
                        "data-dev-file": "/app/src/pages/index.tsx",
                        "data-dev-line": 594,
                        "data-dev-id": "545fba",
                        children: lane.name
                      },
                      void 0,
                      false,
                      {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 613,
                        columnNumber: 21
                      },
                      this
                    ),
                    /* @__PURE__ */ jsxDEV(
                      "p",
                      {
                        className: "mb-6 leading-relaxed",
                        style: {
                          fontFamily: "var(--font-sans)",
                          fontSize: "0.9rem",
                          color: "rgba(245, 237, 228, 0.55)",
                          lineHeight: 1.7
                        },
                        "data-dev-content-key-template": "home.studio.lanes[].description",
                        "data-dev-file": "/app/src/pages/index.tsx",
                        "data-dev-line": 606,
                        "data-dev-id": "21b64f",
                        children: lane.description
                      },
                      void 0,
                      false,
                      {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 625,
                        columnNumber: 21
                      },
                      this
                    ),
                    /* @__PURE__ */ jsxDEV(
                      "span",
                      {
                        className: "text-xs uppercase tracking-widest",
                        style: {
                          color: "#ff7a26",
                          fontFamily: "var(--font-sans)",
                          letterSpacing: "0.15em",
                          opacity: 0.8
                        },
                        "data-dev-content-key-template": "home.studio.lanes[].status",
                        "data-dev-file": "/app/src/pages/index.tsx",
                        "data-dev-line": 618,
                        "data-dev-id": "06d7d1",
                        children: lane.status
                      },
                      void 0,
                      false,
                      {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 637,
                        columnNumber: 21
                      },
                      this
                    )
                  ]
                },
                void 0,
                true,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 588,
                  columnNumber: 19
                },
                this
              ) }, lane.id, false, {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 587,
                columnNumber: 15
              }, this)
            ) }, void 0, false, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 585,
              columnNumber: 13
            }, this)
          ] }, void 0, true, {
            fileName: "/app/src/pages/index.tsx",
            lineNumber: 563,
            columnNumber: 11
          }, this)
        },
        void 0,
        false,
        {
          fileName: "/app/src/pages/index.tsx",
          lineNumber: 558,
          columnNumber: 9
        },
        this
      ),
      /* @__PURE__ */ jsxDEV(LavaDivider, { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 636, "data-dev-id": "784470" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 655,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV(
        "section",
        {
          id: "about",
          className: "relative py-24 overflow-hidden",
          style: { background: "#0a0706" },
          "data-dev-file": "/app/src/pages/index.tsx",
          "data-dev-line": 639,
          "data-dev-id": "8c0c7b",
          children: [
            /* @__PURE__ */ jsxDEV(
              "div",
              {
                className: "absolute pointer-events-none",
                "aria-hidden": "true",
                style: {
                  right: "-10%",
                  top: "20%",
                  width: "500px",
                  height: "500px",
                  background: "radial-gradient(circle, rgba(232,69,28,0.08) 0%, transparent 70%)",
                  borderRadius: "50%"
                },
                "data-dev-file": "/app/src/pages/index.tsx",
                "data-dev-line": 645,
                "data-dev-id": "8d348f"
              },
              void 0,
              false,
              {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 664,
                columnNumber: 11
              },
              this
            ),
            /* @__PURE__ */ jsxDEV("div", { className: "container mx-auto px-6 relative z-10", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 658, "data-dev-id": "8d3490", children: /* @__PURE__ */ jsxDEV("div", { className: "max-w-3xl", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 659, "data-dev-id": "535864", children: [
              /* @__PURE__ */ jsxDEV(FadeIn, { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 660, "data-dev-id": "3d0bdc", children: /* @__PURE__ */ jsxDEV(
                "span",
                {
                  className: "text-xs uppercase tracking-widest mb-6 block",
                  style: { color: "#ff7a26", fontFamily: "var(--font-sans)", letterSpacing: "0.2em" },
                  "data-dev-content-key": "home.about.section_label",
                  "data-dev-bound-text": "true",
                  "data-dev-bound-source-kind": "content-key",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 661,
                  "data-dev-id": "53553f",
                  children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "53553f", guard: { file: "src/pages/index.tsx", tagName: "span", sourceKind: "content-key", contentKey: "home.about.section_label", contentKeyTemplate: null, expressionHash: null }, children: home.about.section_label }, void 0, false, {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 684,
                    columnNumber: 19
                  }, this)
                },
                void 0,
                false,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 680,
                  columnNumber: 17
                },
                this
              ) }, void 0, false, {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 679,
                columnNumber: 15
              }, this),
              /* @__PURE__ */ jsxDEV(FadeIn, { delay: 0.1, "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 669, "data-dev-id": "3d0bdd", children: /* @__PURE__ */ jsxDEV(
                "p",
                {
                  className: "mb-10 leading-relaxed",
                  style: {
                    fontFamily: "var(--font-sans)",
                    fontSize: "clamp(1rem, 2vw, 1.15rem)",
                    color: "rgba(245, 237, 228, 0.7)",
                    lineHeight: 1.85
                  },
                  "data-dev-content-key": "home.about.body",
                  "data-dev-bound-text": "true",
                  "data-dev-bound-source-kind": "content-key",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 670,
                  "data-dev-id": "8d92fe",
                  children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "8d92fe", guard: { file: "src/pages/index.tsx", tagName: "p", sourceKind: "content-key", contentKey: "home.about.body", contentKeyTemplate: null, expressionHash: null }, children: home.about.body }, void 0, false, {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 698,
                    columnNumber: 19
                  }, this)
                },
                void 0,
                false,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 689,
                  columnNumber: 17
                },
                this
              ) }, void 0, false, {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 688,
                columnNumber: 15
              }, this),
              /* @__PURE__ */ jsxDEV(FadeIn, { delay: 0.2, "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 683, "data-dev-id": "3d0bde", children: /* @__PURE__ */ jsxDEV(
                "p",
                {
                  style: {
                    fontFamily: "var(--font-heading)",
                    fontSize: "clamp(1.4rem, 3vw, 2rem)",
                    fontWeight: 700,
                    color: "#f5ede4",
                    borderLeft: "3px solid #ff7a26",
                    paddingLeft: "1.5rem"
                  },
                  "data-dev-content-key": "home.about.closing",
                  "data-dev-bound-text": "true",
                  "data-dev-bound-source-kind": "content-key",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 684,
                  "data-dev-id": "9fab7f",
                  children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "9fab7f", guard: { file: "src/pages/index.tsx", tagName: "p", sourceKind: "content-key", contentKey: "home.about.closing", contentKeyTemplate: null, expressionHash: null }, children: home.about.closing }, void 0, false, {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 713,
                    columnNumber: 19
                  }, this)
                },
                void 0,
                false,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 703,
                  columnNumber: 17
                },
                this
              ) }, void 0, false, {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 702,
                columnNumber: 15
              }, this)
            ] }, void 0, true, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 678,
              columnNumber: 13
            }, this) }, void 0, false, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 677,
              columnNumber: 11
            }, this)
          ]
        },
        void 0,
        true,
        {
          fileName: "/app/src/pages/index.tsx",
          lineNumber: 658,
          columnNumber: 9
        },
        this
      ),
      /* @__PURE__ */ jsxDEV(LavaDivider, { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 701, "data-dev-id": "784471" }, void 0, false, {
        fileName: "/app/src/pages/index.tsx",
        lineNumber: 720,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV(
        "section",
        {
          id: "contact",
          className: "relative py-24",
          style: { background: "#12100e" },
          "data-dev-file": "/app/src/pages/index.tsx",
          "data-dev-line": 704,
          "data-dev-id": "8c0c7c",
          children: /* @__PURE__ */ jsxDEV("div", { className: "container mx-auto px-6", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 709, "data-dev-id": "877150", children: [
            /* @__PURE__ */ jsxDEV(FadeIn, { "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 710, "data-dev-id": "49ee48", children: [
              /* @__PURE__ */ jsxDEV(
                "span",
                {
                  className: "text-xs uppercase tracking-widest mb-6 block",
                  style: { color: "#ff7a26", fontFamily: "var(--font-sans)", letterSpacing: "0.2em" },
                  "data-dev-content-key": "home.contact.section_label",
                  "data-dev-bound-text": "true",
                  "data-dev-bound-source-kind": "content-key",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 711,
                  "data-dev-id": "93c62b",
                  children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "93c62b", guard: { file: "src/pages/index.tsx", tagName: "span", sourceKind: "content-key", contentKey: "home.contact.section_label", contentKeyTemplate: null, expressionHash: null }, children: home.contact.section_label }, void 0, false, {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 734,
                    columnNumber: 17
                  }, this)
                },
                void 0,
                false,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 730,
                  columnNumber: 15
                },
                this
              ),
              /* @__PURE__ */ jsxDEV(
                "h2",
                {
                  className: "mb-12",
                  style: {
                    fontFamily: "var(--font-heading)",
                    fontSize: "clamp(2rem, 4vw, 3rem)",
                    fontWeight: 700,
                    color: "#f5ede4"
                  },
                  "data-dev-content-key": "home.contact.headline",
                  "data-dev-bound-text": "true",
                  "data-dev-bound-source-kind": "content-key",
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 717,
                  "data-dev-id": "3deb53",
                  children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "3deb53", guard: { file: "src/pages/index.tsx", tagName: "h2", sourceKind: "content-key", contentKey: "home.contact.headline", contentKeyTemplate: null, expressionHash: null }, children: home.contact.headline }, void 0, false, {
                    fileName: "/app/src/pages/index.tsx",
                    lineNumber: 745,
                    columnNumber: 17
                  }, this)
                },
                void 0,
                false,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 736,
                  columnNumber: 15
                },
                this
              )
            ] }, void 0, true, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 729,
              columnNumber: 13
            }, this),
            /* @__PURE__ */ jsxDEV("div", { className: "grid grid-cols-1 md:grid-cols-3 gap-6 mb-12", "data-dev-dynamic": "true", "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 730, "data-dev-id": "b82524", children: [
              { label: "Email", value: home.contact.email, href: `mailto:${home.contact.email}` },
              { label: "Storefront", value: home.contact.storefront, href: "https://wpaistudio.gumroad.com" },
              { label: "GitHub", value: home.contact.github, href: "https://github.com/MrWizard94-Compile" }
            ].map(
              (item, i) => /* @__PURE__ */ jsxDEV(FadeIn, { delay: i * 0.1, "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 736, "data-dev-id": "b4309c", children: /* @__PURE__ */ jsxDEV(
                "a",
                {
                  href: item.href,
                  target: item.href.startsWith("mailto") ? void 0 : "_blank",
                  rel: item.href.startsWith("mailto") ? void 0 : "noopener noreferrer",
                  className: "block p-6 transition-all duration-200 group",
                  style: {
                    border: "1px solid rgba(255, 122, 38, 0.15)",
                    borderRadius: "2px"
                  },
                  onMouseEnter: (e) => {
                    e.currentTarget.style.borderColor = "rgba(255, 122, 38, 0.4)";
                    e.currentTarget.style.background = "rgba(255, 122, 38, 0.04)";
                  },
                  onMouseLeave: (e) => {
                    e.currentTarget.style.borderColor = "rgba(255, 122, 38, 0.15)";
                    e.currentTarget.style.background = "transparent";
                  },
                  "data-dev-file": "/app/src/pages/index.tsx",
                  "data-dev-line": 737,
                  "data-dev-id": "76bf6e",
                  children: [
                    /* @__PURE__ */ jsxDEV(
                      "div",
                      {
                        className: "text-xs uppercase tracking-widest mb-2",
                        style: { color: "#ff7a26", fontFamily: "var(--font-sans)", letterSpacing: "0.15em" },
                        "data-dev-dynamic": "true",
                        "data-dev-file": "/app/src/pages/index.tsx",
                        "data-dev-line": 755,
                        "data-dev-id": "bd11c2",
                        children: item.label
                      },
                      void 0,
                      false,
                      {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 774,
                        columnNumber: 21
                      },
                      this
                    ),
                    /* @__PURE__ */ jsxDEV(
                      "div",
                      {
                        className: "text-sm break-all",
                        style: { color: "rgba(245, 237, 228, 0.7)", fontFamily: "var(--font-sans)" },
                        "data-dev-dynamic": "true",
                        "data-dev-file": "/app/src/pages/index.tsx",
                        "data-dev-line": 761,
                        "data-dev-id": "bd11c3",
                        children: item.value
                      },
                      void 0,
                      false,
                      {
                        fileName: "/app/src/pages/index.tsx",
                        lineNumber: 780,
                        columnNumber: 21
                      },
                      this
                    )
                  ]
                },
                void 0,
                true,
                {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 756,
                  columnNumber: 19
                },
                this
              ) }, item.label, false, {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 755,
                columnNumber: 15
              }, this)
            ) }, void 0, false, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 749,
              columnNumber: 13
            }, this),
            /* @__PURE__ */ jsxDEV(FadeIn, { delay: 0.3, "data-dev-file": "/app/src/pages/index.tsx", "data-dev-line": 772, "data-dev-id": "49ee49", children: /* @__PURE__ */ jsxDEV(
              motion.a,
              {
                href: home.contact.cta_url,
                className: "inline-flex items-center gap-3 px-10 py-4 font-semibold text-white",
                style: {
                  background: "linear-gradient(135deg, #ff7a26, #e8451c)",
                  borderRadius: "2px",
                  fontSize: "1rem",
                  letterSpacing: "0.06em",
                  fontFamily: "var(--font-sans)",
                  boxShadow: "0 0 24px rgba(255, 122, 38, 0.35)"
                },
                whileHover: {
                  boxShadow: "0 0 48px rgba(255, 122, 38, 0.65)",
                  scale: 1.02
                },
                whileTap: { scale: 0.98 },
                "data-dev-content-key": "home.contact.cta_label",
                "data-dev-bound-text": "true",
                "data-dev-bound-source-kind": "content-key",
                "data-dev-file": "/app/src/pages/index.tsx",
                "data-dev-line": 773,
                "data-dev-id": "0cdfff",
                children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "0cdfff", guard: { file: "src/pages/index.tsx", tagName: "a", sourceKind: "content-key", contentKey: "home.contact.cta_label", contentKeyTemplate: null, expressionHash: null }, children: home.contact.cta_label }, void 0, false, {
                  fileName: "/app/src/pages/index.tsx",
                  lineNumber: 809,
                  columnNumber: 17
                }, this)
              },
              void 0,
              false,
              {
                fileName: "/app/src/pages/index.tsx",
                lineNumber: 792,
                columnNumber: 15
              },
              this
            ) }, void 0, false, {
              fileName: "/app/src/pages/index.tsx",
              lineNumber: 791,
              columnNumber: 13
            }, this)
          ] }, void 0, true, {
            fileName: "/app/src/pages/index.tsx",
            lineNumber: 728,
            columnNumber: 11
          }, this)
        },
        void 0,
        false,
        {
          fileName: "/app/src/pages/index.tsx",
          lineNumber: 723,
          columnNumber: 9
        },
        this
      )
    ] }, void 0, true, {
      fileName: "/app/src/pages/index.tsx",
      lineNumber: 195,
      columnNumber: 7
    }, this)
  ] }, void 0, true, {
    fileName: "/app/src/pages/index.tsx",
    lineNumber: 171,
    columnNumber: 5
  }, this);
}
_c4 = HomePage;
var _c, _c2, _c3, _c4;
$RefreshReg$(_c, "EmberParticles");
$RefreshReg$(_c2, "FadeIn");
$RefreshReg$(_c3, "LavaDivider");
$RefreshReg$(_c4, "HomePage");
if (import.meta.hot && !inWebWorker) {
  window.$RefreshReg$ = prevRefreshReg;
  window.$RefreshSig$ = prevRefreshSig;
}
if (import.meta.hot && !inWebWorker) {
  RefreshRuntime.__hmr_import(import.meta.url).then((currentExports) => {
    RefreshRuntime.registerExportsForReactRefresh("/app/src/pages/index.tsx", currentExports);
    import.meta.hot.accept((nextExports) => {
      if (!nextExports) return;
      const invalidateMessage = RefreshRuntime.validateRefreshBoundaryAndEnqueueUpdate("/app/src/pages/index.tsx", currentExports, nextExports);
      if (invalidateMessage) import.meta.hot.invalidate(invalidateMessage);
    });
  });
}

//# sourceMappingURL=data:application/json;base64,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QUFBUSxJQUFBa0YsSUFBQUMsS0FBQXBGLEtBQUFrRjtBQUFBLGFBQUFDLElBQUE7QUFBQSxhQUFBQyxLQUFBO0FBQUEsYUFBQXBGLEtBQUE7QUFBQSxhQUFBa0YsS0FBQSIsIm5hbWVzIjpbInVzZVJlZiIsInVzZVN0YXRlIiwiSGVsbWV0IiwibW90aW9uIiwidXNlSW5WaWV3IiwiaG9tZSIsIkVtYmVyUGFydGljbGVzIiwiX3MiLCJwYXJ0aWNsZXMiLCJBcnJheSIsImZyb20iLCJsZW5ndGgiLCJfIiwiaSIsImlkIiwieCIsIk1hdGgiLCJyYW5kb20iLCJ5Iiwic2l6ZSIsImR1cmF0aW9uIiwiZGVsYXkiLCJkcmlmdCIsIm1hcCIsInAiLCJsZWZ0IiwidG9wIiwid2lkdGgiLCJoZWlnaHQiLCJiYWNrZ3JvdW5kIiwiYm94U2hhZG93Iiwib3BhY2l0eSIsInNjYWxlIiwicmVwZWF0IiwiSW5maW5pdHkiLCJlYXNlIiwiRmFkZUluIiwiY2hpbGRyZW4iLCJjbGFzc05hbWUiLCJfczIiLCJyZWYiLCJpblZpZXciLCJvbmNlIiwibWFyZ2luIiwiTGF2YURpdmlkZXIiLCJwb3NpdGlvbiIsImluc2V0IiwiZmlsdGVyIiwiX2MzIiwiSG9tZVBhZ2UiLCJzaXRlIiwianNvbkxkIiwibmFtZSIsInVybCIsImZvdW5kZXIiLCJzYW1lQXMiLCJpc1BhcnRPZiIsImFib3V0IiwiZGF0ZVB1Ymxpc2hlZCIsImRhdGVNb2RpZmllZCIsIkpTT04iLCJzdHJpbmdpZnkiLCJtaW5IZWlnaHQiLCJkaXNwbGF5IiwiYWxpZ25JdGVtcyIsImJvcmRlciIsImNvbG9yIiwibGV0dGVyU3BhY2luZyIsImZvbnRGYW1pbHkiLCJmaWxlIiwidGFnTmFtZSIsInNvdXJjZUtpbmQiLCJjb250ZW50S2V5IiwiY29udGVudEtleVRlbXBsYXRlIiwiZXhwcmVzc2lvbkhhc2giLCJoZXJvIiwiYmFkZ2UiLCJmb250U2l6ZSIsImZvbnRXZWlnaHQiLCJsaW5lSGVpZ2h0IiwiaGVhZGxpbmVfc3RhcnQiLCJ0ZXh0U2hhZG93IiwiaGVhZGxpbmVfYWNjZW50IiwibGVkZSIsInRoZXNpcyIsImN0YV9wcmltYXJ5X3VybCIsImJvcmRlclJhZGl1cyIsImN0YV9wcmltYXJ5IiwiZG9jdW1lbnQiLCJxdWVyeVNlbGVjdG9yIiwic2Nyb2xsSW50b1ZpZXciLCJiZWhhdmlvciIsImJvcmRlckNvbG9yIiwiY3RhX3NlY29uZGFyeSIsInByb2R1Y3RzIiwic2VjdGlvbl9sYWJlbCIsIml0ZW1zIiwiaXRlbSIsImUiLCJjdXJyZW50VGFyZ2V0Iiwic3R5bGUiLCJjYXRlZ29yeSIsInByaWNlIiwiZGVzY3JpcHRpb24iLCJidXlfdXJsIiwiYnV5X2xhYmVsIiwiZnJlZV91cmwiLCJmcmVlX2xhYmVsIiwic3R1ZGlvIiwiaGVhZGxpbmUiLCJsYW5lcyIsImxhbmUiLCJib3JkZXJMZWZ0IiwiYm9yZGVyUmlnaHQiLCJzdGF0dXMiLCJyaWdodCIsImJvZHkiLCJwYWRkaW5nTGVmdCIsImNsb3NpbmciLCJjb250YWN0IiwibGFiZWwiLCJ2YWx1ZSIsImVtYWlsIiwiaHJlZiIsInN0b3JlZnJvbnQiLCJnaXRodWIiLCJzdGFydHNXaXRoIiwidW5kZWZpbmVkIiwiY3RhX3VybCIsImN0YV9sYWJlbCIsIl9jNCIsIl9jIiwiX2MyIl0sImlnbm9yZUxpc3QiOltdLCJzb3VyY2VzIjpbImluZGV4LnRzeCJdLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyB1c2VSZWYsIHVzZVN0YXRlIH0gZnJvbSAncmVhY3QnO1xuaW1wb3J0IHsgSGVsbWV0IH0gZnJvbSAnQGRyLnBvZ29kaW4vcmVhY3QtaGVsbWV0JztcbmltcG9ydCB7IG1vdGlvbiwgdXNlSW5WaWV3IH0gZnJvbSAnbW90aW9uL3JlYWN0JztcbmltcG9ydCB7IGhvbWUgfSBmcm9tICd2aXJ0dWFsOmNvbnRlbnQnO1xuXG4vLyDilIDilIAgRW1iZXIgcGFydGljbGUgc3lzdGVtIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgFxuaW50ZXJmYWNlIFBhcnRpY2xlIHtcbiAgaWQ6IG51bWJlcjtcbiAgeDogbnVtYmVyO1xuICB5OiBudW1iZXI7XG4gIHNpemU6IG51bWJlcjtcbiAgZHVyYXRpb246IG51bWJlcjtcbiAgZGVsYXk6IG51bWJlcjtcbiAgZHJpZnQ6IG51bWJlcjtcbn1cblxuZnVuY3Rpb24gRW1iZXJQYXJ0aWNsZXMoKSB7XG4gIGNvbnN0IFtwYXJ0aWNsZXNdID0gdXNlU3RhdGU8UGFydGljbGVbXT4oKCkgPT5cbiAgICBBcnJheS5mcm9tKHsgbGVuZ3RoOiAyOCB9LCAoXywgaSkgPT4gKHtcbiAgICAgIGlkOiBpLFxuICAgICAgeDogTWF0aC5yYW5kb20oKSAqIDEwMCxcbiAgICAgIHk6IE1hdGgucmFuZG9tKCkgKiAxMDAsXG4gICAgICBzaXplOiBNYXRoLnJhbmRvbSgpICogMyArIDEsXG4gICAgICBkdXJhdGlvbjogTWF0aC5yYW5kb20oKSAqIDggKyA2LFxuICAgICAgZGVsYXk6IE1hdGgucmFuZG9tKCkgKiA2LFxuICAgICAgZHJpZnQ6IChNYXRoLnJhbmRvbSgpIC0gMC41KSAqIDYwLFxuICAgIH0pKVxuICApO1xuXG4gIHJldHVybiAoXG4gICAgPGRpdiBjbGFzc05hbWU9XCJhYnNvbHV0ZSBpbnNldC0wIG92ZXJmbG93LWhpZGRlbiBwb2ludGVyLWV2ZW50cy1ub25lXCIgYXJpYS1oaWRkZW49XCJ0cnVlXCI+XG4gICAgICB7cGFydGljbGVzLm1hcCgocCkgPT4gKFxuICAgICAgICA8bW90aW9uLmRpdlxuICAgICAgICAgIGtleT17cC5pZH1cbiAgICAgICAgICBjbGFzc05hbWU9XCJhYnNvbHV0ZSByb3VuZGVkLWZ1bGxcIlxuICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICBsZWZ0OiBgJHtwLnh9JWAsXG4gICAgICAgICAgICB0b3A6IGAke3AueX0lYCxcbiAgICAgICAgICAgIHdpZHRoOiBwLnNpemUsXG4gICAgICAgICAgICBoZWlnaHQ6IHAuc2l6ZSxcbiAgICAgICAgICAgIGJhY2tncm91bmQ6IHAuc2l6ZSA+IDMgPyAnI2ZmN2EyNicgOiAnI2U4NDUxYycsXG4gICAgICAgICAgICBib3hTaGFkb3c6IGAwIDAgJHtwLnNpemUgKiAzfXB4ICR7cC5zaXplID4gMyA/ICcjZmY3YTI2JyA6ICcjZTg0NTFjJ31gLFxuICAgICAgICAgIH19XG4gICAgICAgICAgYW5pbWF0ZT17e1xuICAgICAgICAgICAgeTogWzAsIC0xMjAsIC0yMDBdLFxuICAgICAgICAgICAgeDogWzAsIHAuZHJpZnRdLFxuICAgICAgICAgICAgb3BhY2l0eTogWzAsIDAuOCwgMF0sXG4gICAgICAgICAgICBzY2FsZTogWzAuNSwgMSwgMC4yXSxcbiAgICAgICAgICB9fVxuICAgICAgICAgIHRyYW5zaXRpb249e3tcbiAgICAgICAgICAgIGR1cmF0aW9uOiBwLmR1cmF0aW9uLFxuICAgICAgICAgICAgZGVsYXk6IHAuZGVsYXksXG4gICAgICAgICAgICByZXBlYXQ6IEluZmluaXR5LFxuICAgICAgICAgICAgZWFzZTogJ2Vhc2VPdXQnLFxuICAgICAgICAgIH19XG4gICAgICAgIC8+XG4gICAgICApKX1cbiAgICA8L2Rpdj5cbiAgKTtcbn1cblxuLy8g4pSA4pSAIEZhZGUtaW4gb24gc2Nyb2xsIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgFxuZnVuY3Rpb24gRmFkZUluKHtcbiAgY2hpbGRyZW4sXG4gIGRlbGF5ID0gMCxcbiAgY2xhc3NOYW1lID0gJycsXG59OiB7XG4gIGNoaWxkcmVuOiBSZWFjdC5SZWFjdE5vZGU7XG4gIGRlbGF5PzogbnVtYmVyO1xuICBjbGFzc05hbWU/OiBzdHJpbmc7XG59KSB7XG4gIGNvbnN0IHJlZiA9IHVzZVJlZihudWxsKTtcbiAgY29uc3QgaW5WaWV3ID0gdXNlSW5WaWV3KHJlZiwgeyBvbmNlOiB0cnVlLCBtYXJnaW46ICctODBweCcgfSk7XG5cbiAgcmV0dXJuIChcbiAgICA8bW90aW9uLmRpdlxuICAgICAgcmVmPXtyZWZ9XG4gICAgICBjbGFzc05hbWU9e2NsYXNzTmFtZX1cbiAgICAgIGluaXRpYWw9e3sgb3BhY2l0eTogMCwgeTogMzIgfX1cbiAgICAgIGFuaW1hdGU9e2luVmlldyA/IHsgb3BhY2l0eTogMSwgeTogMCB9IDoge319XG4gICAgICB0cmFuc2l0aW9uPXt7IGR1cmF0aW9uOiAwLjcsIGRlbGF5LCBlYXNlOiAnZWFzZU91dCcgYXMgY29uc3QgfX1cbiAgICA+XG4gICAgICB7Y2hpbGRyZW59XG4gICAgPC9tb3Rpb24uZGl2PlxuICApO1xufVxuXG4vLyDilIDilIAgTGF2YSB2ZWluIGRpdmlkZXIg4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSAXG5mdW5jdGlvbiBMYXZhRGl2aWRlcigpIHtcbiAgcmV0dXJuIChcbiAgICA8ZGl2IGNsYXNzTmFtZT1cInJlbGF0aXZlIHctZnVsbCBvdmVyZmxvdy1oaWRkZW5cIiBzdHlsZT17eyBoZWlnaHQ6ICczcHgnIH19IGFyaWEtaGlkZGVuPVwidHJ1ZVwiPlxuICAgICAgPGRpdlxuICAgICAgICBzdHlsZT17e1xuICAgICAgICAgIHBvc2l0aW9uOiAnYWJzb2x1dGUnLFxuICAgICAgICAgIGluc2V0OiAwLFxuICAgICAgICAgIGJhY2tncm91bmQ6XG4gICAgICAgICAgICAnbGluZWFyLWdyYWRpZW50KDkwZGVnLCB0cmFuc3BhcmVudCAwJSwgI2U4NDUxYyAyMCUsICNmZjdhMjYgNTAlLCAjZTg0NTFjIDgwJSwgdHJhbnNwYXJlbnQgMTAwJSknLFxuICAgICAgICAgIG9wYWNpdHk6IDAuNSxcbiAgICAgICAgfX1cbiAgICAgIC8+XG4gICAgICA8ZGl2XG4gICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgcG9zaXRpb246ICdhYnNvbHV0ZScsXG4gICAgICAgICAgaW5zZXQ6IDAsXG4gICAgICAgICAgYmFja2dyb3VuZDpcbiAgICAgICAgICAgICdsaW5lYXItZ3JhZGllbnQoOTBkZWcsIHRyYW5zcGFyZW50IDAlLCByZ2JhKDI1NSwxMjIsMzgsMC4zKSAzMCUsIHJnYmEoMjU1LDEyMiwzOCwwLjYpIDUwJSwgcmdiYSgyNTUsMTIyLDM4LDAuMykgNzAlLCB0cmFuc3BhcmVudCAxMDAlKScsXG4gICAgICAgICAgZmlsdGVyOiAnYmx1cig0cHgpJyxcbiAgICAgICAgfX1cbiAgICAgIC8+XG4gICAgPC9kaXY+XG4gICk7XG59XG5cbi8vIOKUgOKUgCBNYWluIHBhZ2Ug4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSAXG5leHBvcnQgZGVmYXVsdCBmdW5jdGlvbiBIb21lUGFnZSgpIHtcbiAgY29uc3Qgc2l0ZSA9ICdodHRwczovL3dwYWlzdHVkaW8ubmV0JztcblxuICBjb25zdCBqc29uTGQgPSB7XG4gICAgJ0Bjb250ZXh0JzogJ2h0dHBzOi8vc2NoZW1hLm9yZycsXG4gICAgJ0BncmFwaCc6IFtcbiAgICAgIHtcbiAgICAgICAgJ0B0eXBlJzogJ1dlYlNpdGUnLFxuICAgICAgICAnQGlkJzogYCR7c2l0ZX0vI3dlYnNpdGVgLFxuICAgICAgICBuYW1lOiAnV2l6YXJkIFByb2R1Y3Rpb25zIEFJIFN0dWRpbycsXG4gICAgICAgIHVybDogYCR7c2l0ZX0vYCxcbiAgICAgIH0sXG4gICAgICB7XG4gICAgICAgICdAdHlwZSc6ICdPcmdhbml6YXRpb24nLFxuICAgICAgICAnQGlkJzogYCR7c2l0ZX0vI29yZ2FuaXphdGlvbmAsXG4gICAgICAgIG5hbWU6ICdXaXphcmQgUHJvZHVjdGlvbnMgQUkgU3R1ZGlvJyxcbiAgICAgICAgdXJsOiBgJHtzaXRlfS9gLFxuICAgICAgICBmb3VuZGVyOiB7ICdAdHlwZSc6ICdQZXJzb24nLCBuYW1lOiAnUm9iIEJ1bGtsZXknIH0sXG4gICAgICAgIHNhbWVBczogW1xuICAgICAgICAgICdodHRwczovL3dwYWlzdHVkaW8uZ3Vtcm9hZC5jb20nLFxuICAgICAgICAgICdodHRwczovL2dpdGh1Yi5jb20vTXJXaXphcmQ5NC1Db21waWxlJyxcbiAgICAgICAgXSxcbiAgICAgIH0sXG4gICAgICB7XG4gICAgICAgICdAdHlwZSc6ICdXZWJQYWdlJyxcbiAgICAgICAgJ0BpZCc6IGAke3NpdGV9LyN3ZWJwYWdlYCxcbiAgICAgICAgdXJsOiBgJHtzaXRlfS9gLFxuICAgICAgICBuYW1lOiAnV2l6YXJkIFByb2R1Y3Rpb25zIEFJIFN0dWRpbyDigJQgRm9yZ2luZyB0aGUgZnV0dXJlIG9mIGNyZWF0aXZlIG1lZGlhJyxcbiAgICAgICAgaXNQYXJ0T2Y6IHsgJ0BpZCc6IGAke3NpdGV9LyN3ZWJzaXRlYCB9LFxuICAgICAgICBhYm91dDogeyAnQGlkJzogYCR7c2l0ZX0vI29yZ2FuaXphdGlvbmAgfSxcbiAgICAgICAgZGF0ZVB1Ymxpc2hlZDogJzIwMjYtMDctMTAnLFxuICAgICAgICBkYXRlTW9kaWZpZWQ6ICcyMDI2LTA3LTEwJyxcbiAgICAgIH0sXG4gICAgXSxcbiAgfTtcblxuICByZXR1cm4gKFxuICAgIDw+XG4gICAgICA8SGVsbWV0PlxuICAgICAgICA8dGl0bGU+V2l6YXJkIFByb2R1Y3Rpb25zIEFJIFN0dWRpbyDigJQgRm9yZ2luZyB0aGUgZnV0dXJlIG9mIGNyZWF0aXZlIG1lZGlhPC90aXRsZT5cbiAgICAgICAgPG1ldGFcbiAgICAgICAgICBuYW1lPVwiZGVzY3JpcHRpb25cIlxuICAgICAgICAgIGNvbnRlbnQ9XCJXUEFJOiBBSSBjcmVhdGl2ZSBzdHVkaW8gc2hpcHBpbmcgaGVhdnkgbXVzaWMsIGRldmVsb3BlciB0b29scywgZ2FtZXMsIGFuZCBBSSByZXNlYXJjaC4gSHVtYW4tZGlyZWN0ZWQsIEFJLWFzc2lzdGVkLiBSZXBvRm9yZ2UgUHJvLCBUaGUgTWl4aW4gRmllbGQgTWFudWFsLCBhbmQgbW9yZS5cIlxuICAgICAgICAvPlxuICAgICAgICA8bGluayByZWw9XCJjYW5vbmljYWxcIiBocmVmPXtzaXRlfSAvPlxuICAgICAgICA8bWV0YSBwcm9wZXJ0eT1cIm9nOnRpdGxlXCIgY29udGVudD1cIldpemFyZCBQcm9kdWN0aW9ucyBBSSBTdHVkaW9cIiAvPlxuICAgICAgICA8bWV0YVxuICAgICAgICAgIHByb3BlcnR5PVwib2c6ZGVzY3JpcHRpb25cIlxuICAgICAgICAgIGNvbnRlbnQ9XCJBSSBpcyBpbiB0aGUgbmFtZS4gVGhlIHdpemFyZCBpcyBpbiB0aGUgd29yay4gSGVhdnkgbXVzaWMsIGRldmVsb3BlciB0b29scywgZ2FtZXMsIGFuZCBkZWVwIHJlc2VhcmNoIOKAlCBmb3JnZWQgdW5kZXIgb25lIGJyYW5kLlwiXG4gICAgICAgIC8+XG4gICAgICAgIDxtZXRhIHByb3BlcnR5PVwib2c6dHlwZVwiIGNvbnRlbnQ9XCJ3ZWJzaXRlXCIgLz5cbiAgICAgICAgPG1ldGEgcHJvcGVydHk9XCJvZzp1cmxcIiBjb250ZW50PXtzaXRlfSAvPlxuICAgICAgICA8bWV0YSBuYW1lPVwidHdpdHRlcjpjYXJkXCIgY29udGVudD1cInN1bW1hcnlfbGFyZ2VfaW1hZ2VcIiAvPlxuICAgICAgICA8bWV0YSBuYW1lPVwidHdpdHRlcjp0aXRsZVwiIGNvbnRlbnQ9XCJXaXphcmQgUHJvZHVjdGlvbnMgQUkgU3R1ZGlvXCIgLz5cbiAgICAgICAgPG1ldGFcbiAgICAgICAgICBuYW1lPVwidHdpdHRlcjpkZXNjcmlwdGlvblwiXG4gICAgICAgICAgY29udGVudD1cIkFJIGlzIGluIHRoZSBuYW1lLiBUaGUgd2l6YXJkIGlzIGluIHRoZSB3b3JrLlwiXG4gICAgICAgIC8+XG4gICAgICAgIDxzY3JpcHQgdHlwZT1cImFwcGxpY2F0aW9uL2xkK2pzb25cIj57SlNPTi5zdHJpbmdpZnkoanNvbkxkKX08L3NjcmlwdD5cbiAgICAgIDwvSGVsbWV0PlxuXG4gICAgICA8bWFpbj5cbiAgICAgICAgey8qIOKUgOKUgCBIRVJPIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgCAqL31cbiAgICAgICAgPHNlY3Rpb25cbiAgICAgICAgICBpZD1cImhlcm9cIlxuICAgICAgICAgIGNsYXNzTmFtZT1cInJlbGF0aXZlIG92ZXJmbG93LWhpZGRlblwiXG4gICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgIGJhY2tncm91bmQ6ICdsaW5lYXItZ3JhZGllbnQoMTgwZGVnLCAjMGEwNzA2IDAlLCAjMTIxMDBlIDYwJSwgIzBhMDcwNiAxMDAlKScsXG4gICAgICAgICAgICBtaW5IZWlnaHQ6ICcxMDB2aCcsXG4gICAgICAgICAgICBkaXNwbGF5OiAnZmxleCcsXG4gICAgICAgICAgICBhbGlnbkl0ZW1zOiAnY2VudGVyJyxcbiAgICAgICAgICB9fVxuICAgICAgICA+XG4gICAgICAgICAgey8qIEJhY2tncm91bmQgZm9yZ2UgaW1hZ2UgKi99XG4gICAgICAgICAgPGRpdlxuICAgICAgICAgICAgY2xhc3NOYW1lPVwiYWJzb2x1dGUgaW5zZXQtMCBwb2ludGVyLWV2ZW50cy1ub25lXCJcbiAgICAgICAgICAgIGFyaWEtaGlkZGVuPVwidHJ1ZVwiXG4gICAgICAgICAgICBzdHlsZT17eyBvcGFjaXR5OiAwLjE4IH19XG4gICAgICAgICAgPlxuICAgICAgICAgICAgPGltZ1xuICAgICAgICAgICAgICBzcmM9XCIvYWlyby1hc3NldHMvaW1hZ2VzL3BhZ2VzL2hvbWUvaGVyby1mb3JnZVwiXG4gICAgICAgICAgICAgIGFsdD1cIlwiXG4gICAgICAgICAgICAgIGNsYXNzTmFtZT1cInctZnVsbCBoLWZ1bGwgb2JqZWN0LWNvdmVyXCJcbiAgICAgICAgICAgICAgbG9hZGluZz1cImVhZ2VyXCJcbiAgICAgICAgICAgICAgZmV0Y2hQcmlvcml0eT1cImhpZ2hcIlxuICAgICAgICAgICAgICB3aWR0aD17MTkyMH1cbiAgICAgICAgICAgICAgaGVpZ2h0PXsxMDgwfVxuICAgICAgICAgICAgLz5cbiAgICAgICAgICA8L2Rpdj5cblxuICAgICAgICAgIHsvKiBSYWRpYWwgZW1iZXIgZ2xvdyAqL31cbiAgICAgICAgICA8ZGl2XG4gICAgICAgICAgICBjbGFzc05hbWU9XCJhYnNvbHV0ZSBpbnNldC0wIHBvaW50ZXItZXZlbnRzLW5vbmVcIlxuICAgICAgICAgICAgYXJpYS1oaWRkZW49XCJ0cnVlXCJcbiAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgIGJhY2tncm91bmQ6XG4gICAgICAgICAgICAgICAgJ3JhZGlhbC1ncmFkaWVudChlbGxpcHNlIDcwJSA2MCUgYXQgNTAlIDYwJSwgcmdiYSgyMzIsNjksMjgsMC4xMikgMCUsIHRyYW5zcGFyZW50IDcwJSknLFxuICAgICAgICAgICAgfX1cbiAgICAgICAgICAvPlxuXG4gICAgICAgICAgPEVtYmVyUGFydGljbGVzIC8+XG5cbiAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT1cImNvbnRhaW5lciBteC1hdXRvIHB4LTYgcHktMjQgcmVsYXRpdmUgei0xMFwiPlxuICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9XCJtYXgtdy00eGxcIj5cbiAgICAgICAgICAgICAgey8qIEJhZGdlICovfVxuICAgICAgICAgICAgICA8bW90aW9uLmRpdlxuICAgICAgICAgICAgICAgIGluaXRpYWw9e3sgb3BhY2l0eTogMCwgeTogLTEyIH19XG4gICAgICAgICAgICAgICAgYW5pbWF0ZT17eyBvcGFjaXR5OiAxLCB5OiAwIH19XG4gICAgICAgICAgICAgICAgdHJhbnNpdGlvbj17eyBkdXJhdGlvbjogMC42LCBlYXNlOiAnZWFzZU91dCcgYXMgY29uc3QgfX1cbiAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJpbmxpbmUtZmxleCBpdGVtcy1jZW50ZXIgbWItOFwiXG4gICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICA8c3BhblxuICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwidGV4dC14cyBmb250LXNlbWlib2xkIHB4LTQgcHktMiB0cmFja2luZy13aWRlc3QgdXBwZXJjYXNlXCJcbiAgICAgICAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgICAgICAgIGJvcmRlcjogJzFweCBzb2xpZCByZ2JhKDI1NSwgMTIyLCAzOCwgMC40KScsXG4gICAgICAgICAgICAgICAgICAgIGNvbG9yOiAnI2ZmN2EyNicsXG4gICAgICAgICAgICAgICAgICAgIGJhY2tncm91bmQ6ICdyZ2JhKDI1NSwgMTIyLCAzOCwgMC4wNiknLFxuICAgICAgICAgICAgICAgICAgICBsZXR0ZXJTcGFjaW5nOiAnMC4xOGVtJyxcbiAgICAgICAgICAgICAgICAgICAgZm9udEZhbWlseTogJ3ZhcigtLWZvbnQtc2FucyknLFxuICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICA+XG4gICAgICAgICAgICAgICAgICB7aG9tZS5oZXJvLmJhZGdlfVxuICAgICAgICAgICAgICAgIDwvc3Bhbj5cbiAgICAgICAgICAgICAgPC9tb3Rpb24uZGl2PlxuXG4gICAgICAgICAgICAgIHsvKiBIZWFkbGluZSAqL31cbiAgICAgICAgICAgICAgPG1vdGlvbi5oMVxuICAgICAgICAgICAgICAgIGluaXRpYWw9e3sgb3BhY2l0eTogMCwgeTogMjQgfX1cbiAgICAgICAgICAgICAgICBhbmltYXRlPXt7IG9wYWNpdHk6IDEsIHk6IDAgfX1cbiAgICAgICAgICAgICAgICB0cmFuc2l0aW9uPXt7IGR1cmF0aW9uOiAwLjgsIGRlbGF5OiAwLjEsIGVhc2U6ICdlYXNlT3V0JyBhcyBjb25zdCB9fVxuICAgICAgICAgICAgICAgIGNsYXNzTmFtZT1cIm1iLTYgbGVhZGluZy10aWdodFwiXG4gICAgICAgICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgICAgICAgIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LWhlYWRpbmcpJyxcbiAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAnY2xhbXAoMi44cmVtLCA3dncsIDUuNXJlbSknLFxuICAgICAgICAgICAgICAgICAgZm9udFdlaWdodDogOTAwLFxuICAgICAgICAgICAgICAgICAgY29sb3I6ICcjZjVlZGU0JyxcbiAgICAgICAgICAgICAgICAgIGxpbmVIZWlnaHQ6IDEuMDUsXG4gICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgIDxzcGFuPntob21lLmhlcm8uaGVhZGxpbmVfc3RhcnR9IDwvc3Bhbj5cbiAgICAgICAgICAgICAgICA8c3BhblxuICAgICAgICAgICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgICAgICAgICAgY29sb3I6ICcjZmY3YTI2JyxcbiAgICAgICAgICAgICAgICAgICAgdGV4dFNoYWRvdzogJzAgMCA0MHB4IHJnYmEoMjU1LCAxMjIsIDM4LCAwLjUpJyxcbiAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAge2hvbWUuaGVyby5oZWFkbGluZV9hY2NlbnR9XG4gICAgICAgICAgICAgICAgPC9zcGFuPlxuICAgICAgICAgICAgICA8L21vdGlvbi5oMT5cblxuICAgICAgICAgICAgICB7LyogTGVkZSAqL31cbiAgICAgICAgICAgICAgPG1vdGlvbi5wXG4gICAgICAgICAgICAgICAgaW5pdGlhbD17eyBvcGFjaXR5OiAwLCB5OiAyMCB9fVxuICAgICAgICAgICAgICAgIGFuaW1hdGU9e3sgb3BhY2l0eTogMSwgeTogMCB9fVxuICAgICAgICAgICAgICAgIHRyYW5zaXRpb249e3sgZHVyYXRpb246IDAuOCwgZGVsYXk6IDAuMjUsIGVhc2U6ICdlYXNlT3V0JyBhcyBjb25zdCB9fVxuICAgICAgICAgICAgICAgIGNsYXNzTmFtZT1cIm1iLTggbWF4LXctMnhsIGxlYWRpbmctcmVsYXhlZFwiXG4gICAgICAgICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgICAgICAgIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LXNhbnMpJyxcbiAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAnY2xhbXAoMXJlbSwgMnZ3LCAxLjJyZW0pJyxcbiAgICAgICAgICAgICAgICAgIGNvbG9yOiAncmdiYSgyNDUsIDIzNywgMjI4LCAwLjcpJyxcbiAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICA+XG4gICAgICAgICAgICAgICAge2hvbWUuaGVyby5sZWRlfVxuICAgICAgICAgICAgICA8L21vdGlvbi5wPlxuXG4gICAgICAgICAgICAgIHsvKiBUaGVzaXMgKi99XG4gICAgICAgICAgICAgIDxtb3Rpb24ucFxuICAgICAgICAgICAgICAgIGluaXRpYWw9e3sgb3BhY2l0eTogMCB9fVxuICAgICAgICAgICAgICAgIGFuaW1hdGU9e3sgb3BhY2l0eTogMSB9fVxuICAgICAgICAgICAgICAgIHRyYW5zaXRpb249e3sgZHVyYXRpb246IDEsIGRlbGF5OiAwLjQgfX1cbiAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJtYi0xMCBpdGFsaWNcIlxuICAgICAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgICAgICBmb250RmFtaWx5OiAndmFyKC0tZm9udC1oZWFkaW5nKScsXG4gICAgICAgICAgICAgICAgICBmb250U2l6ZTogJ2NsYW1wKDEuMXJlbSwgMi41dncsIDEuNXJlbSknLFxuICAgICAgICAgICAgICAgICAgY29sb3I6ICdyZ2JhKDI0NSwgMjM3LCAyMjgsIDAuNSknLFxuICAgICAgICAgICAgICAgICAgbGV0dGVyU3BhY2luZzogJzAuMDJlbScsXG4gICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgIFwie2hvbWUuaGVyby50aGVzaXN9XCJcbiAgICAgICAgICAgICAgPC9tb3Rpb24ucD5cblxuICAgICAgICAgICAgICB7LyogQ1RBcyAqL31cbiAgICAgICAgICAgICAgPG1vdGlvbi5kaXZcbiAgICAgICAgICAgICAgICBpbml0aWFsPXt7IG9wYWNpdHk6IDAsIHk6IDE2IH19XG4gICAgICAgICAgICAgICAgYW5pbWF0ZT17eyBvcGFjaXR5OiAxLCB5OiAwIH19XG4gICAgICAgICAgICAgICAgdHJhbnNpdGlvbj17eyBkdXJhdGlvbjogMC43LCBkZWxheTogMC41LCBlYXNlOiAnZWFzZU91dCcgYXMgY29uc3QgfX1cbiAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJmbGV4IGZsZXgtd3JhcCBnYXAtNFwiXG4gICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICA8bW90aW9uLmFcbiAgICAgICAgICAgICAgICAgIGhyZWY9e2hvbWUuaGVyby5jdGFfcHJpbWFyeV91cmx9XG4gICAgICAgICAgICAgICAgICB0YXJnZXQ9XCJfYmxhbmtcIlxuICAgICAgICAgICAgICAgICAgcmVsPVwibm9vcGVuZXIgbm9yZWZlcnJlclwiXG4gICAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJpbmxpbmUtZmxleCBpdGVtcy1jZW50ZXIgZ2FwLTIgcHgtOCBweS00IGZvbnQtc2VtaWJvbGQgdGV4dC13aGl0ZSB0cmFuc2l0aW9uLWFsbCBkdXJhdGlvbi0yMDBcIlxuICAgICAgICAgICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgICAgICAgICAgYmFja2dyb3VuZDogJ2xpbmVhci1ncmFkaWVudCgxMzVkZWcsICNmZjdhMjYsICNlODQ1MWMpJyxcbiAgICAgICAgICAgICAgICAgICAgYm9yZGVyUmFkaXVzOiAnMnB4JyxcbiAgICAgICAgICAgICAgICAgICAgZm9udFNpemU6ICcwLjk1cmVtJyxcbiAgICAgICAgICAgICAgICAgICAgbGV0dGVyU3BhY2luZzogJzAuMDZlbScsXG4gICAgICAgICAgICAgICAgICAgIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LXNhbnMpJyxcbiAgICAgICAgICAgICAgICAgICAgYm94U2hhZG93OiAnMCAwIDI0cHggcmdiYSgyNTUsIDEyMiwgMzgsIDAuNCknLFxuICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICAgIHdoaWxlSG92ZXI9e3tcbiAgICAgICAgICAgICAgICAgICAgYm94U2hhZG93OiAnMCAwIDQ4cHggcmdiYSgyNTUsIDEyMiwgMzgsIDAuNyknLFxuICAgICAgICAgICAgICAgICAgICBzY2FsZTogMS4wMixcbiAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgICB3aGlsZVRhcD17eyBzY2FsZTogMC45OCB9fVxuICAgICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICAgIHtob21lLmhlcm8uY3RhX3ByaW1hcnl9XG4gICAgICAgICAgICAgICAgPC9tb3Rpb24uYT5cblxuICAgICAgICAgICAgICAgIDxtb3Rpb24uYnV0dG9uXG4gICAgICAgICAgICAgICAgICBvbkNsaWNrPXsoKSA9PiB7XG4gICAgICAgICAgICAgICAgICAgIGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoJyNwcm9kdWN0cycpPy5zY3JvbGxJbnRvVmlldyh7IGJlaGF2aW9yOiAnc21vb3RoJyB9KTtcbiAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJpbmxpbmUtZmxleCBpdGVtcy1jZW50ZXIgZ2FwLTIgcHgtOCBweS00IGZvbnQtc2VtaWJvbGQgdHJhbnNpdGlvbi1hbGwgZHVyYXRpb24tMjAwIGN1cnNvci1wb2ludGVyXCJcbiAgICAgICAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgICAgICAgIGJvcmRlcjogJzFweCBzb2xpZCByZ2JhKDI1NSwgMTIyLCAzOCwgMC40KScsXG4gICAgICAgICAgICAgICAgICAgIGNvbG9yOiAncmdiYSgyNDUsIDIzNywgMjI4LCAwLjg1KScsXG4gICAgICAgICAgICAgICAgICAgIGJvcmRlclJhZGl1czogJzJweCcsXG4gICAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAnMC45NXJlbScsXG4gICAgICAgICAgICAgICAgICAgIGxldHRlclNwYWNpbmc6ICcwLjA2ZW0nLFxuICAgICAgICAgICAgICAgICAgICBmb250RmFtaWx5OiAndmFyKC0tZm9udC1zYW5zKScsXG4gICAgICAgICAgICAgICAgICAgIGJhY2tncm91bmQ6ICd0cmFuc3BhcmVudCcsXG4gICAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICAgICAgd2hpbGVIb3Zlcj17e1xuICAgICAgICAgICAgICAgICAgICBib3JkZXJDb2xvcjogJ3JnYmEoMjU1LCAxMjIsIDM4LCAwLjgpJyxcbiAgICAgICAgICAgICAgICAgICAgY29sb3I6ICcjZmY3YTI2JyxcbiAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgICB3aGlsZVRhcD17eyBzY2FsZTogMC45OCB9fVxuICAgICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICAgIHtob21lLmhlcm8uY3RhX3NlY29uZGFyeX1cbiAgICAgICAgICAgICAgICA8L21vdGlvbi5idXR0b24+XG4gICAgICAgICAgICAgIDwvbW90aW9uLmRpdj5cbiAgICAgICAgICAgIDwvZGl2PlxuICAgICAgICAgIDwvZGl2PlxuXG4gICAgICAgICAgey8qIEJvdHRvbSBmYWRlICovfVxuICAgICAgICAgIDxkaXZcbiAgICAgICAgICAgIGNsYXNzTmFtZT1cImFic29sdXRlIGJvdHRvbS0wIGxlZnQtMCByaWdodC0wIHBvaW50ZXItZXZlbnRzLW5vbmVcIlxuICAgICAgICAgICAgYXJpYS1oaWRkZW49XCJ0cnVlXCJcbiAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgIGhlaWdodDogJzEyMHB4JyxcbiAgICAgICAgICAgICAgYmFja2dyb3VuZDogJ2xpbmVhci1ncmFkaWVudCh0byBib3R0b20sIHRyYW5zcGFyZW50LCAjMGEwNzA2KScsXG4gICAgICAgICAgICB9fVxuICAgICAgICAgIC8+XG4gICAgICAgIDwvc2VjdGlvbj5cblxuICAgICAgICA8TGF2YURpdmlkZXIgLz5cblxuICAgICAgICB7Lyog4pSA4pSAIFBST0RVQ1RTIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgCAqL31cbiAgICAgICAgPHNlY3Rpb25cbiAgICAgICAgICBpZD1cInByb2R1Y3RzXCJcbiAgICAgICAgICBjbGFzc05hbWU9XCJyZWxhdGl2ZSBweS0yNCBvdmVyZmxvdy1oaWRkZW5cIlxuICAgICAgICAgIHN0eWxlPXt7IGJhY2tncm91bmQ6ICcjMGEwNzA2JyB9fVxuICAgICAgICA+XG4gICAgICAgICAgey8qIEJhc2FsdCB0ZXh0dXJlIGJnICovfVxuICAgICAgICAgIDxkaXZcbiAgICAgICAgICAgIGNsYXNzTmFtZT1cImFic29sdXRlIGluc2V0LTAgcG9pbnRlci1ldmVudHMtbm9uZVwiXG4gICAgICAgICAgICBhcmlhLWhpZGRlbj1cInRydWVcIlxuICAgICAgICAgICAgc3R5bGU9e3sgb3BhY2l0eTogMC4wNyB9fVxuICAgICAgICAgID5cbiAgICAgICAgICAgIDxpbWdcbiAgICAgICAgICAgICAgc3JjPVwiL2Fpcm8tYXNzZXRzL2ltYWdlcy9wYWdlcy9ob21lL3Byb2R1Y3RzLWJnXCJcbiAgICAgICAgICAgICAgYWx0PVwiXCJcbiAgICAgICAgICAgICAgY2xhc3NOYW1lPVwidy1mdWxsIGgtZnVsbCBvYmplY3QtY292ZXJcIlxuICAgICAgICAgICAgICBsb2FkaW5nPVwibGF6eVwiXG4gICAgICAgICAgICAgIHdpZHRoPXsxOTIwfVxuICAgICAgICAgICAgICBoZWlnaHQ9ezEwODB9XG4gICAgICAgICAgICAvPlxuICAgICAgICAgIDwvZGl2PlxuXG4gICAgICAgICAgPGRpdiBjbGFzc05hbWU9XCJjb250YWluZXIgbXgtYXV0byBweC02IHJlbGF0aXZlIHotMTBcIj5cbiAgICAgICAgICAgIDxGYWRlSW4+XG4gICAgICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPVwibWItMTRcIj5cbiAgICAgICAgICAgICAgICA8c3BhblxuICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwidGV4dC14cyB1cHBlcmNhc2UgdHJhY2tpbmctd2lkZXN0IG1iLTMgYmxvY2tcIlxuICAgICAgICAgICAgICAgICAgc3R5bGU9e3sgY29sb3I6ICcjZmY3YTI2JywgZm9udEZhbWlseTogJ3ZhcigtLWZvbnQtc2FucyknLCBsZXR0ZXJTcGFjaW5nOiAnMC4yZW0nIH19XG4gICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAge2hvbWUucHJvZHVjdHMuc2VjdGlvbl9sYWJlbH1cbiAgICAgICAgICAgICAgICA8L3NwYW4+XG4gICAgICAgICAgICAgICAgPGgyXG4gICAgICAgICAgICAgICAgICBzdHlsZT17e1xuICAgICAgICAgICAgICAgICAgICBmb250RmFtaWx5OiAndmFyKC0tZm9udC1oZWFkaW5nKScsXG4gICAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAnY2xhbXAoMnJlbSwgNHZ3LCAzcmVtKScsXG4gICAgICAgICAgICAgICAgICAgIGZvbnRXZWlnaHQ6IDcwMCxcbiAgICAgICAgICAgICAgICAgICAgY29sb3I6ICcjZjVlZGU0JyxcbiAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAgRm9yZ2VkLiBTaGlwcGVkLiBGb3Igc2FsZS5cbiAgICAgICAgICAgICAgICA8L2gyPlxuICAgICAgICAgICAgICA8L2Rpdj5cbiAgICAgICAgICAgIDwvRmFkZUluPlxuXG4gICAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT1cImdyaWQgZ3JpZC1jb2xzLTEgbGc6Z3JpZC1jb2xzLTIgZ2FwLThcIj5cbiAgICAgICAgICAgICAge2hvbWUucHJvZHVjdHMuaXRlbXMubWFwKChpdGVtLCBpKSA9PiAoXG4gICAgICAgICAgICAgICAgPEZhZGVJbiBrZXk9e2l0ZW0uaWR9IGRlbGF5PXtpICogMC4xNX0+XG4gICAgICAgICAgICAgICAgICA8ZGl2XG4gICAgICAgICAgICAgICAgICAgIGNsYXNzTmFtZT1cInJlbGF0aXZlIHAtOCBoLWZ1bGwgZmxleCBmbGV4LWNvbCB0cmFuc2l0aW9uLWFsbCBkdXJhdGlvbi0zMDAgZ3JvdXBcIlxuICAgICAgICAgICAgICAgICAgICBzdHlsZT17e1xuICAgICAgICAgICAgICAgICAgICAgIGJhY2tncm91bmQ6ICdsaW5lYXItZ3JhZGllbnQoMTM1ZGVnLCAjMTIxMDBlIDAlLCAjMGYwZDBiIDEwMCUpJyxcbiAgICAgICAgICAgICAgICAgICAgICBib3JkZXI6ICcxcHggc29saWQgcmdiYSgyNTUsIDEyMiwgMzgsIDAuMTUpJyxcbiAgICAgICAgICAgICAgICAgICAgICBib3JkZXJSYWRpdXM6ICcycHgnLFxuICAgICAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICAgICAgICBvbk1vdXNlRW50ZXI9eyhlKSA9PiB7XG4gICAgICAgICAgICAgICAgICAgICAgKGUuY3VycmVudFRhcmdldCBhcyBIVE1MRWxlbWVudCkuc3R5bGUuYm9yZGVyQ29sb3IgPSAncmdiYSgyNTUsIDEyMiwgMzgsIDAuNDUpJztcbiAgICAgICAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5ib3hTaGFkb3cgPSAnMCAwIDQwcHggcmdiYSgyNTUsIDEyMiwgMzgsIDAuMSksIGluc2V0IDAgMCA0MHB4IHJnYmEoMjU1LCAxMjIsIDM4LCAwLjAzKSc7XG4gICAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgICAgIG9uTW91c2VMZWF2ZT17KGUpID0+IHtcbiAgICAgICAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5ib3JkZXJDb2xvciA9ICdyZ2JhKDI1NSwgMTIyLCAzOCwgMC4xNSknO1xuICAgICAgICAgICAgICAgICAgICAgIChlLmN1cnJlbnRUYXJnZXQgYXMgSFRNTEVsZW1lbnQpLnN0eWxlLmJveFNoYWRvdyA9ICdub25lJztcbiAgICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICAgICAgey8qIENhdGVnb3J5ICsgcHJpY2UgKi99XG4gICAgICAgICAgICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPVwiZmxleCBpdGVtcy1jZW50ZXIganVzdGlmeS1iZXR3ZWVuIG1iLTZcIj5cbiAgICAgICAgICAgICAgICAgICAgICA8c3BhblxuICAgICAgICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwidGV4dC14cyB1cHBlcmNhc2UgdHJhY2tpbmctd2lkZXN0IHB4LTMgcHktMVwiXG4gICAgICAgICAgICAgICAgICAgICAgICBzdHlsZT17e1xuICAgICAgICAgICAgICAgICAgICAgICAgICBjb2xvcjogJyNmZjdhMjYnLFxuICAgICAgICAgICAgICAgICAgICAgICAgICBib3JkZXI6ICcxcHggc29saWQgcmdiYSgyNTUsIDEyMiwgMzgsIDAuMyknLFxuICAgICAgICAgICAgICAgICAgICAgICAgICBmb250RmFtaWx5OiAndmFyKC0tZm9udC1zYW5zKScsXG4gICAgICAgICAgICAgICAgICAgICAgICAgIGxldHRlclNwYWNpbmc6ICcwLjE1ZW0nLFxuICAgICAgICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICAgICAgICA+XG4gICAgICAgICAgICAgICAgICAgICAgICB7aXRlbS5jYXRlZ29yeX1cbiAgICAgICAgICAgICAgICAgICAgICA8L3NwYW4+XG4gICAgICAgICAgICAgICAgICAgICAgPHNwYW5cbiAgICAgICAgICAgICAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LWhlYWRpbmcpJyxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgZm9udFNpemU6ICcxLjhyZW0nLFxuICAgICAgICAgICAgICAgICAgICAgICAgICBmb250V2VpZ2h0OiA3MDAsXG4gICAgICAgICAgICAgICAgICAgICAgICAgIGNvbG9yOiAnI2ZmN2EyNicsXG4gICAgICAgICAgICAgICAgICAgICAgICAgIHRleHRTaGFkb3c6ICcwIDAgMjBweCByZ2JhKDI1NSwgMTIyLCAzOCwgMC40KScsXG4gICAgICAgICAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICAgICAgICAgIHtpdGVtLnByaWNlfVxuICAgICAgICAgICAgICAgICAgICAgIDwvc3Bhbj5cbiAgICAgICAgICAgICAgICAgICAgPC9kaXY+XG5cbiAgICAgICAgICAgICAgICAgICAgey8qIE5hbWUgKi99XG4gICAgICAgICAgICAgICAgICAgIDxoM1xuICAgICAgICAgICAgICAgICAgICAgIGNsYXNzTmFtZT1cIm1iLTRcIlxuICAgICAgICAgICAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgICAgICAgICAgICBmb250RmFtaWx5OiAndmFyKC0tZm9udC1oZWFkaW5nKScsXG4gICAgICAgICAgICAgICAgICAgICAgICBmb250U2l6ZTogJ2NsYW1wKDEuNHJlbSwgMi41dncsIDEuOXJlbSknLFxuICAgICAgICAgICAgICAgICAgICAgICAgZm9udFdlaWdodDogNzAwLFxuICAgICAgICAgICAgICAgICAgICAgICAgY29sb3I6ICcjZjVlZGU0JyxcbiAgICAgICAgICAgICAgICAgICAgICAgIGxpbmVIZWlnaHQ6IDEuMixcbiAgICAgICAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICAgICAgICA+XG4gICAgICAgICAgICAgICAgICAgICAge2l0ZW0ubmFtZX1cbiAgICAgICAgICAgICAgICAgICAgPC9oMz5cblxuICAgICAgICAgICAgICAgICAgICB7LyogRGVzY3JpcHRpb24gKi99XG4gICAgICAgICAgICAgICAgICAgIDxwXG4gICAgICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwibWItOCBmbGV4LTEgbGVhZGluZy1yZWxheGVkXCJcbiAgICAgICAgICAgICAgICAgICAgICBzdHlsZT17e1xuICAgICAgICAgICAgICAgICAgICAgICAgZm9udEZhbWlseTogJ3ZhcigtLWZvbnQtc2FucyknLFxuICAgICAgICAgICAgICAgICAgICAgICAgZm9udFNpemU6ICcwLjk1cmVtJyxcbiAgICAgICAgICAgICAgICAgICAgICAgIGNvbG9yOiAncmdiYSgyNDUsIDIzNywgMjI4LCAwLjYpJyxcbiAgICAgICAgICAgICAgICAgICAgICAgIGxpbmVIZWlnaHQ6IDEuNyxcbiAgICAgICAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICAgICAgICA+XG4gICAgICAgICAgICAgICAgICAgICAge2l0ZW0uZGVzY3JpcHRpb259XG4gICAgICAgICAgICAgICAgICAgIDwvcD5cblxuICAgICAgICAgICAgICAgICAgICB7LyogQWN0aW9ucyAqL31cbiAgICAgICAgICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9XCJmbGV4IGZsZXgtd3JhcCBnYXAtM1wiPlxuICAgICAgICAgICAgICAgICAgICAgIDxhXG4gICAgICAgICAgICAgICAgICAgICAgICBocmVmPXtpdGVtLmJ1eV91cmx9XG4gICAgICAgICAgICAgICAgICAgICAgICB0YXJnZXQ9XCJfYmxhbmtcIlxuICAgICAgICAgICAgICAgICAgICAgICAgcmVsPVwibm9vcGVuZXIgbm9yZWZlcnJlclwiXG4gICAgICAgICAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJpbmxpbmUtZmxleCBpdGVtcy1jZW50ZXIgcHgtNiBweS0zIGZvbnQtc2VtaWJvbGQgdGV4dC13aGl0ZSB0cmFuc2l0aW9uLWFsbCBkdXJhdGlvbi0yMDBcIlxuICAgICAgICAgICAgICAgICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgICAgICAgICAgICAgICAgYmFja2dyb3VuZDogJ2xpbmVhci1ncmFkaWVudCgxMzVkZWcsICNmZjdhMjYsICNlODQ1MWMpJyxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgYm9yZGVyUmFkaXVzOiAnMnB4JyxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgZm9udFNpemU6ICcwLjg3NXJlbScsXG4gICAgICAgICAgICAgICAgICAgICAgICAgIGxldHRlclNwYWNpbmc6ICcwLjA1ZW0nLFxuICAgICAgICAgICAgICAgICAgICAgICAgICBmb250RmFtaWx5OiAndmFyKC0tZm9udC1zYW5zKScsXG4gICAgICAgICAgICAgICAgICAgICAgICAgIGJveFNoYWRvdzogJzAgMCAxNnB4IHJnYmEoMjU1LCAxMjIsIDM4LCAwLjI1KScsXG4gICAgICAgICAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICAgICAgICAgICAgb25Nb3VzZUVudGVyPXsoZSkgPT4ge1xuICAgICAgICAgICAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5ib3hTaGFkb3cgPSAnMCAwIDMycHggcmdiYSgyNTUsIDEyMiwgMzgsIDAuNSknO1xuICAgICAgICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICAgICAgICAgIG9uTW91c2VMZWF2ZT17KGUpID0+IHtcbiAgICAgICAgICAgICAgICAgICAgICAgICAgKGUuY3VycmVudFRhcmdldCBhcyBIVE1MRWxlbWVudCkuc3R5bGUuYm94U2hhZG93ID0gJzAgMCAxNnB4IHJnYmEoMjU1LCAxMjIsIDM4LCAwLjI1KSc7XG4gICAgICAgICAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICAgICAgICAgIHtpdGVtLmJ1eV9sYWJlbH1cbiAgICAgICAgICAgICAgICAgICAgICA8L2E+XG4gICAgICAgICAgICAgICAgICAgICAgPGFcbiAgICAgICAgICAgICAgICAgICAgICAgIGhyZWY9e2l0ZW0uZnJlZV91cmx9XG4gICAgICAgICAgICAgICAgICAgICAgICB0YXJnZXQ9XCJfYmxhbmtcIlxuICAgICAgICAgICAgICAgICAgICAgICAgcmVsPVwibm9vcGVuZXIgbm9yZWZlcnJlclwiXG4gICAgICAgICAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJpbmxpbmUtZmxleCBpdGVtcy1jZW50ZXIgcHgtNiBweS0zIGZvbnQtbWVkaXVtIHRyYW5zaXRpb24tYWxsIGR1cmF0aW9uLTIwMFwiXG4gICAgICAgICAgICAgICAgICAgICAgICBzdHlsZT17e1xuICAgICAgICAgICAgICAgICAgICAgICAgICBib3JkZXI6ICcxcHggc29saWQgcmdiYSgyNTUsIDEyMiwgMzgsIDAuMjUpJyxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgY29sb3I6ICdyZ2JhKDI0NSwgMjM3LCAyMjgsIDAuNiknLFxuICAgICAgICAgICAgICAgICAgICAgICAgICBib3JkZXJSYWRpdXM6ICcycHgnLFxuICAgICAgICAgICAgICAgICAgICAgICAgICBmb250U2l6ZTogJzAuODc1cmVtJyxcbiAgICAgICAgICAgICAgICAgICAgICAgICAgbGV0dGVyU3BhY2luZzogJzAuMDVlbScsXG4gICAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LXNhbnMpJyxcbiAgICAgICAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgICAgICAgICBvbk1vdXNlRW50ZXI9eyhlKSA9PiB7XG4gICAgICAgICAgICAgICAgICAgICAgICAgIChlLmN1cnJlbnRUYXJnZXQgYXMgSFRNTEVsZW1lbnQpLnN0eWxlLmNvbG9yID0gJyNmZjdhMjYnO1xuICAgICAgICAgICAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5ib3JkZXJDb2xvciA9ICdyZ2JhKDI1NSwgMTIyLCAzOCwgMC41KSc7XG4gICAgICAgICAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICAgICAgICAgICAgb25Nb3VzZUxlYXZlPXsoZSkgPT4ge1xuICAgICAgICAgICAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5jb2xvciA9ICdyZ2JhKDI0NSwgMjM3LCAyMjgsIDAuNiknO1xuICAgICAgICAgICAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5ib3JkZXJDb2xvciA9ICdyZ2JhKDI1NSwgMTIyLCAzOCwgMC4yNSknO1xuICAgICAgICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICAgICAgICA+XG4gICAgICAgICAgICAgICAgICAgICAgICB7aXRlbS5mcmVlX2xhYmVsfVxuICAgICAgICAgICAgICAgICAgICAgIDwvYT5cbiAgICAgICAgICAgICAgICAgICAgPC9kaXY+XG4gICAgICAgICAgICAgICAgICA8L2Rpdj5cbiAgICAgICAgICAgICAgICA8L0ZhZGVJbj5cbiAgICAgICAgICAgICAgKSl9XG4gICAgICAgICAgICA8L2Rpdj5cbiAgICAgICAgICA8L2Rpdj5cbiAgICAgICAgPC9zZWN0aW9uPlxuXG4gICAgICAgIDxMYXZhRGl2aWRlciAvPlxuXG4gICAgICAgIHsvKiDilIDilIAgU1RVRElPIExBTkVTIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgCAqL31cbiAgICAgICAgPHNlY3Rpb25cbiAgICAgICAgICBpZD1cInN0dWRpb1wiXG4gICAgICAgICAgY2xhc3NOYW1lPVwicmVsYXRpdmUgcHktMjRcIlxuICAgICAgICAgIHN0eWxlPXt7IGJhY2tncm91bmQ6ICcjMTIxMDBlJyB9fVxuICAgICAgICA+XG4gICAgICAgICAgPGRpdiBjbGFzc05hbWU9XCJjb250YWluZXIgbXgtYXV0byBweC02XCI+XG4gICAgICAgICAgICA8RmFkZUluPlxuICAgICAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT1cIm1iLTE0XCI+XG4gICAgICAgICAgICAgICAgPHNwYW5cbiAgICAgICAgICAgICAgICAgIGNsYXNzTmFtZT1cInRleHQteHMgdXBwZXJjYXNlIHRyYWNraW5nLXdpZGVzdCBtYi0zIGJsb2NrXCJcbiAgICAgICAgICAgICAgICAgIHN0eWxlPXt7IGNvbG9yOiAnI2ZmN2EyNicsIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LXNhbnMpJywgbGV0dGVyU3BhY2luZzogJzAuMmVtJyB9fVxuICAgICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICAgIHtob21lLnN0dWRpby5zZWN0aW9uX2xhYmVsfVxuICAgICAgICAgICAgICAgIDwvc3Bhbj5cbiAgICAgICAgICAgICAgICA8aDJcbiAgICAgICAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgICAgICAgIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LWhlYWRpbmcpJyxcbiAgICAgICAgICAgICAgICAgICAgZm9udFNpemU6ICdjbGFtcCgycmVtLCA0dncsIDNyZW0pJyxcbiAgICAgICAgICAgICAgICAgICAgZm9udFdlaWdodDogNzAwLFxuICAgICAgICAgICAgICAgICAgICBjb2xvcjogJyNmNWVkZTQnLFxuICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICA+XG4gICAgICAgICAgICAgICAgICB7aG9tZS5zdHVkaW8uaGVhZGxpbmV9XG4gICAgICAgICAgICAgICAgPC9oMj5cbiAgICAgICAgICAgICAgPC9kaXY+XG4gICAgICAgICAgICA8L0ZhZGVJbj5cblxuICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9XCJncmlkIGdyaWQtY29scy0xIG1kOmdyaWQtY29scy0zIGdhcC0wXCI+XG4gICAgICAgICAgICAgIHtob21lLnN0dWRpby5sYW5lcy5tYXAoKGxhbmUsIGkpID0+IChcbiAgICAgICAgICAgICAgICA8RmFkZUluIGtleT17bGFuZS5pZH0gZGVsYXk9e2kgKiAwLjEyfT5cbiAgICAgICAgICAgICAgICAgIDxkaXZcbiAgICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwicmVsYXRpdmUgcC04IGgtZnVsbCB0cmFuc2l0aW9uLWFsbCBkdXJhdGlvbi0zMDBcIlxuICAgICAgICAgICAgICAgICAgICBzdHlsZT17e1xuICAgICAgICAgICAgICAgICAgICAgIGJvcmRlckxlZnQ6IGkgPT09IDAgPyAnMnB4IHNvbGlkIHJnYmEoMjU1LCAxMjIsIDM4LCAwLjMpJyA6ICcxcHggc29saWQgcmdiYSgyNTUsIDEyMiwgMzgsIDAuMSknLFxuICAgICAgICAgICAgICAgICAgICAgIGJvcmRlclJpZ2h0OiBpID09PSAyID8gJzJweCBzb2xpZCByZ2JhKDI1NSwgMTIyLCAzOCwgMC4zKScgOiAnbm9uZScsXG4gICAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgICAgIG9uTW91c2VFbnRlcj17KGUpID0+IHtcbiAgICAgICAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5iYWNrZ3JvdW5kID0gJ3JnYmEoMjU1LCAxMjIsIDM4LCAwLjA0KSc7XG4gICAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgICAgIG9uTW91c2VMZWF2ZT17KGUpID0+IHtcbiAgICAgICAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5iYWNrZ3JvdW5kID0gJ3RyYW5zcGFyZW50JztcbiAgICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICAgICAgey8qIExhbmUgbnVtYmVyICovfVxuICAgICAgICAgICAgICAgICAgICA8ZGl2XG4gICAgICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwidGV4dC02eGwgZm9udC1ibGFjayBtYi00IHNlbGVjdC1ub25lXCJcbiAgICAgICAgICAgICAgICAgICAgICBzdHlsZT17e1xuICAgICAgICAgICAgICAgICAgICAgICAgZm9udEZhbWlseTogJ3ZhcigtLWZvbnQtaGVhZGluZyknLFxuICAgICAgICAgICAgICAgICAgICAgICAgY29sb3I6ICdyZ2JhKDI1NSwgMTIyLCAzOCwgMC4wOCknLFxuICAgICAgICAgICAgICAgICAgICAgICAgbGluZUhlaWdodDogMSxcbiAgICAgICAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICAgICAgICA+XG4gICAgICAgICAgICAgICAgICAgICAgMHtpICsgMX1cbiAgICAgICAgICAgICAgICAgICAgPC9kaXY+XG5cbiAgICAgICAgICAgICAgICAgICAgPGgzXG4gICAgICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwibWItM1wiXG4gICAgICAgICAgICAgICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LWhlYWRpbmcpJyxcbiAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAnMS41cmVtJyxcbiAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRXZWlnaHQ6IDcwMCxcbiAgICAgICAgICAgICAgICAgICAgICAgIGNvbG9yOiAnI2Y1ZWRlNCcsXG4gICAgICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAgICAgIHtsYW5lLm5hbWV9XG4gICAgICAgICAgICAgICAgICAgIDwvaDM+XG5cbiAgICAgICAgICAgICAgICAgICAgPHBcbiAgICAgICAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJtYi02IGxlYWRpbmctcmVsYXhlZFwiXG4gICAgICAgICAgICAgICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LXNhbnMpJyxcbiAgICAgICAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAnMC45cmVtJyxcbiAgICAgICAgICAgICAgICAgICAgICAgIGNvbG9yOiAncmdiYSgyNDUsIDIzNywgMjI4LCAwLjU1KScsXG4gICAgICAgICAgICAgICAgICAgICAgICBsaW5lSGVpZ2h0OiAxLjcsXG4gICAgICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAgICAgIHtsYW5lLmRlc2NyaXB0aW9ufVxuICAgICAgICAgICAgICAgICAgICA8L3A+XG5cbiAgICAgICAgICAgICAgICAgICAgPHNwYW5cbiAgICAgICAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJ0ZXh0LXhzIHVwcGVyY2FzZSB0cmFja2luZy13aWRlc3RcIlxuICAgICAgICAgICAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgICAgICAgICAgICBjb2xvcjogJyNmZjdhMjYnLFxuICAgICAgICAgICAgICAgICAgICAgICAgZm9udEZhbWlseTogJ3ZhcigtLWZvbnQtc2FucyknLFxuICAgICAgICAgICAgICAgICAgICAgICAgbGV0dGVyU3BhY2luZzogJzAuMTVlbScsXG4gICAgICAgICAgICAgICAgICAgICAgICBvcGFjaXR5OiAwLjgsXG4gICAgICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAgICAgIHtsYW5lLnN0YXR1c31cbiAgICAgICAgICAgICAgICAgICAgPC9zcGFuPlxuICAgICAgICAgICAgICAgICAgPC9kaXY+XG4gICAgICAgICAgICAgICAgPC9GYWRlSW4+XG4gICAgICAgICAgICAgICkpfVxuICAgICAgICAgICAgPC9kaXY+XG4gICAgICAgICAgPC9kaXY+XG4gICAgICAgIDwvc2VjdGlvbj5cblxuICAgICAgICA8TGF2YURpdmlkZXIgLz5cblxuICAgICAgICB7Lyog4pSA4pSAIEFCT1VUIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgCAqL31cbiAgICAgICAgPHNlY3Rpb25cbiAgICAgICAgICBpZD1cImFib3V0XCJcbiAgICAgICAgICBjbGFzc05hbWU9XCJyZWxhdGl2ZSBweS0yNCBvdmVyZmxvdy1oaWRkZW5cIlxuICAgICAgICAgIHN0eWxlPXt7IGJhY2tncm91bmQ6ICcjMGEwNzA2JyB9fVxuICAgICAgICA+XG4gICAgICAgICAgey8qIEVtYmVyIGdsb3cgYWNjZW50ICovfVxuICAgICAgICAgIDxkaXZcbiAgICAgICAgICAgIGNsYXNzTmFtZT1cImFic29sdXRlIHBvaW50ZXItZXZlbnRzLW5vbmVcIlxuICAgICAgICAgICAgYXJpYS1oaWRkZW49XCJ0cnVlXCJcbiAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgIHJpZ2h0OiAnLTEwJScsXG4gICAgICAgICAgICAgIHRvcDogJzIwJScsXG4gICAgICAgICAgICAgIHdpZHRoOiAnNTAwcHgnLFxuICAgICAgICAgICAgICBoZWlnaHQ6ICc1MDBweCcsXG4gICAgICAgICAgICAgIGJhY2tncm91bmQ6ICdyYWRpYWwtZ3JhZGllbnQoY2lyY2xlLCByZ2JhKDIzMiw2OSwyOCwwLjA4KSAwJSwgdHJhbnNwYXJlbnQgNzAlKScsXG4gICAgICAgICAgICAgIGJvcmRlclJhZGl1czogJzUwJScsXG4gICAgICAgICAgICB9fVxuICAgICAgICAgIC8+XG5cbiAgICAgICAgICA8ZGl2IGNsYXNzTmFtZT1cImNvbnRhaW5lciBteC1hdXRvIHB4LTYgcmVsYXRpdmUgei0xMFwiPlxuICAgICAgICAgICAgPGRpdiBjbGFzc05hbWU9XCJtYXgtdy0zeGxcIj5cbiAgICAgICAgICAgICAgPEZhZGVJbj5cbiAgICAgICAgICAgICAgICA8c3BhblxuICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwidGV4dC14cyB1cHBlcmNhc2UgdHJhY2tpbmctd2lkZXN0IG1iLTYgYmxvY2tcIlxuICAgICAgICAgICAgICAgICAgc3R5bGU9e3sgY29sb3I6ICcjZmY3YTI2JywgZm9udEZhbWlseTogJ3ZhcigtLWZvbnQtc2FucyknLCBsZXR0ZXJTcGFjaW5nOiAnMC4yZW0nIH19XG4gICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAge2hvbWUuYWJvdXQuc2VjdGlvbl9sYWJlbH1cbiAgICAgICAgICAgICAgICA8L3NwYW4+XG4gICAgICAgICAgICAgIDwvRmFkZUluPlxuXG4gICAgICAgICAgICAgIDxGYWRlSW4gZGVsYXk9ezAuMX0+XG4gICAgICAgICAgICAgICAgPHBcbiAgICAgICAgICAgICAgICAgIGNsYXNzTmFtZT1cIm1iLTEwIGxlYWRpbmctcmVsYXhlZFwiXG4gICAgICAgICAgICAgICAgICBzdHlsZT17e1xuICAgICAgICAgICAgICAgICAgICBmb250RmFtaWx5OiAndmFyKC0tZm9udC1zYW5zKScsXG4gICAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAnY2xhbXAoMXJlbSwgMnZ3LCAxLjE1cmVtKScsXG4gICAgICAgICAgICAgICAgICAgIGNvbG9yOiAncmdiYSgyNDUsIDIzNywgMjI4LCAwLjcpJyxcbiAgICAgICAgICAgICAgICAgICAgbGluZUhlaWdodDogMS44NSxcbiAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAge2hvbWUuYWJvdXQuYm9keX1cbiAgICAgICAgICAgICAgICA8L3A+XG4gICAgICAgICAgICAgIDwvRmFkZUluPlxuXG4gICAgICAgICAgICAgIDxGYWRlSW4gZGVsYXk9ezAuMn0+XG4gICAgICAgICAgICAgICAgPHBcbiAgICAgICAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgICAgICAgIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LWhlYWRpbmcpJyxcbiAgICAgICAgICAgICAgICAgICAgZm9udFNpemU6ICdjbGFtcCgxLjRyZW0sIDN2dywgMnJlbSknLFxuICAgICAgICAgICAgICAgICAgICBmb250V2VpZ2h0OiA3MDAsXG4gICAgICAgICAgICAgICAgICAgIGNvbG9yOiAnI2Y1ZWRlNCcsXG4gICAgICAgICAgICAgICAgICAgIGJvcmRlckxlZnQ6ICczcHggc29saWQgI2ZmN2EyNicsXG4gICAgICAgICAgICAgICAgICAgIHBhZGRpbmdMZWZ0OiAnMS41cmVtJyxcbiAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAge2hvbWUuYWJvdXQuY2xvc2luZ31cbiAgICAgICAgICAgICAgICA8L3A+XG4gICAgICAgICAgICAgIDwvRmFkZUluPlxuICAgICAgICAgICAgPC9kaXY+XG4gICAgICAgICAgPC9kaXY+XG4gICAgICAgIDwvc2VjdGlvbj5cblxuICAgICAgICA8TGF2YURpdmlkZXIgLz5cblxuICAgICAgICB7Lyog4pSA4pSAIENPTlRBQ1Qg4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSAICovfVxuICAgICAgICA8c2VjdGlvblxuICAgICAgICAgIGlkPVwiY29udGFjdFwiXG4gICAgICAgICAgY2xhc3NOYW1lPVwicmVsYXRpdmUgcHktMjRcIlxuICAgICAgICAgIHN0eWxlPXt7IGJhY2tncm91bmQ6ICcjMTIxMDBlJyB9fVxuICAgICAgICA+XG4gICAgICAgICAgPGRpdiBjbGFzc05hbWU9XCJjb250YWluZXIgbXgtYXV0byBweC02XCI+XG4gICAgICAgICAgICA8RmFkZUluPlxuICAgICAgICAgICAgICA8c3BhblxuICAgICAgICAgICAgICAgIGNsYXNzTmFtZT1cInRleHQteHMgdXBwZXJjYXNlIHRyYWNraW5nLXdpZGVzdCBtYi02IGJsb2NrXCJcbiAgICAgICAgICAgICAgICBzdHlsZT17eyBjb2xvcjogJyNmZjdhMjYnLCBmb250RmFtaWx5OiAndmFyKC0tZm9udC1zYW5zKScsIGxldHRlclNwYWNpbmc6ICcwLjJlbScgfX1cbiAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgIHtob21lLmNvbnRhY3Quc2VjdGlvbl9sYWJlbH1cbiAgICAgICAgICAgICAgPC9zcGFuPlxuICAgICAgICAgICAgICA8aDJcbiAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJtYi0xMlwiXG4gICAgICAgICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgICAgICAgIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LWhlYWRpbmcpJyxcbiAgICAgICAgICAgICAgICAgIGZvbnRTaXplOiAnY2xhbXAoMnJlbSwgNHZ3LCAzcmVtKScsXG4gICAgICAgICAgICAgICAgICBmb250V2VpZ2h0OiA3MDAsXG4gICAgICAgICAgICAgICAgICBjb2xvcjogJyNmNWVkZTQnLFxuICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICB7aG9tZS5jb250YWN0LmhlYWRsaW5lfVxuICAgICAgICAgICAgICA8L2gyPlxuICAgICAgICAgICAgPC9GYWRlSW4+XG5cbiAgICAgICAgICAgIDxkaXYgY2xhc3NOYW1lPVwiZ3JpZCBncmlkLWNvbHMtMSBtZDpncmlkLWNvbHMtMyBnYXAtNiBtYi0xMlwiPlxuICAgICAgICAgICAgICB7W1xuICAgICAgICAgICAgICAgIHsgbGFiZWw6ICdFbWFpbCcsIHZhbHVlOiBob21lLmNvbnRhY3QuZW1haWwsIGhyZWY6IGBtYWlsdG86JHtob21lLmNvbnRhY3QuZW1haWx9YCB9LFxuICAgICAgICAgICAgICAgIHsgbGFiZWw6ICdTdG9yZWZyb250JywgdmFsdWU6IGhvbWUuY29udGFjdC5zdG9yZWZyb250LCBocmVmOiAnaHR0cHM6Ly93cGFpc3R1ZGlvLmd1bXJvYWQuY29tJyB9LFxuICAgICAgICAgICAgICAgIHsgbGFiZWw6ICdHaXRIdWInLCB2YWx1ZTogaG9tZS5jb250YWN0LmdpdGh1YiwgaHJlZjogJ2h0dHBzOi8vZ2l0aHViLmNvbS9NcldpemFyZDk0LUNvbXBpbGUnIH0sXG4gICAgICAgICAgICAgIF0ubWFwKChpdGVtLCBpKSA9PiAoXG4gICAgICAgICAgICAgICAgPEZhZGVJbiBrZXk9e2l0ZW0ubGFiZWx9IGRlbGF5PXtpICogMC4xfT5cbiAgICAgICAgICAgICAgICAgIDxhXG4gICAgICAgICAgICAgICAgICAgIGhyZWY9e2l0ZW0uaHJlZn1cbiAgICAgICAgICAgICAgICAgICAgdGFyZ2V0PXtpdGVtLmhyZWYuc3RhcnRzV2l0aCgnbWFpbHRvJykgPyB1bmRlZmluZWQgOiAnX2JsYW5rJ31cbiAgICAgICAgICAgICAgICAgICAgcmVsPXtpdGVtLmhyZWYuc3RhcnRzV2l0aCgnbWFpbHRvJykgPyB1bmRlZmluZWQgOiAnbm9vcGVuZXIgbm9yZWZlcnJlcid9XG4gICAgICAgICAgICAgICAgICAgIGNsYXNzTmFtZT1cImJsb2NrIHAtNiB0cmFuc2l0aW9uLWFsbCBkdXJhdGlvbi0yMDAgZ3JvdXBcIlxuICAgICAgICAgICAgICAgICAgICBzdHlsZT17e1xuICAgICAgICAgICAgICAgICAgICAgIGJvcmRlcjogJzFweCBzb2xpZCByZ2JhKDI1NSwgMTIyLCAzOCwgMC4xNSknLFxuICAgICAgICAgICAgICAgICAgICAgIGJvcmRlclJhZGl1czogJzJweCcsXG4gICAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgICAgIG9uTW91c2VFbnRlcj17KGUpID0+IHtcbiAgICAgICAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5ib3JkZXJDb2xvciA9ICdyZ2JhKDI1NSwgMTIyLCAzOCwgMC40KSc7XG4gICAgICAgICAgICAgICAgICAgICAgKGUuY3VycmVudFRhcmdldCBhcyBIVE1MRWxlbWVudCkuc3R5bGUuYmFja2dyb3VuZCA9ICdyZ2JhKDI1NSwgMTIyLCAzOCwgMC4wNCknO1xuICAgICAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICAgICAgICBvbk1vdXNlTGVhdmU9eyhlKSA9PiB7XG4gICAgICAgICAgICAgICAgICAgICAgKGUuY3VycmVudFRhcmdldCBhcyBIVE1MRWxlbWVudCkuc3R5bGUuYm9yZGVyQ29sb3IgPSAncmdiYSgyNTUsIDEyMiwgMzgsIDAuMTUpJztcbiAgICAgICAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5iYWNrZ3JvdW5kID0gJ3RyYW5zcGFyZW50JztcbiAgICAgICAgICAgICAgICAgICAgfX1cbiAgICAgICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICAgICAgPGRpdlxuICAgICAgICAgICAgICAgICAgICAgIGNsYXNzTmFtZT1cInRleHQteHMgdXBwZXJjYXNlIHRyYWNraW5nLXdpZGVzdCBtYi0yXCJcbiAgICAgICAgICAgICAgICAgICAgICBzdHlsZT17eyBjb2xvcjogJyNmZjdhMjYnLCBmb250RmFtaWx5OiAndmFyKC0tZm9udC1zYW5zKScsIGxldHRlclNwYWNpbmc6ICcwLjE1ZW0nIH19XG4gICAgICAgICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICAgICAgICB7aXRlbS5sYWJlbH1cbiAgICAgICAgICAgICAgICAgICAgPC9kaXY+XG4gICAgICAgICAgICAgICAgICAgIDxkaXZcbiAgICAgICAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJ0ZXh0LXNtIGJyZWFrLWFsbFwiXG4gICAgICAgICAgICAgICAgICAgICAgc3R5bGU9e3sgY29sb3I6ICdyZ2JhKDI0NSwgMjM3LCAyMjgsIDAuNyknLCBmb250RmFtaWx5OiAndmFyKC0tZm9udC1zYW5zKScgfX1cbiAgICAgICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAgICAgIHtpdGVtLnZhbHVlfVxuICAgICAgICAgICAgICAgICAgICA8L2Rpdj5cbiAgICAgICAgICAgICAgICAgIDwvYT5cbiAgICAgICAgICAgICAgICA8L0ZhZGVJbj5cbiAgICAgICAgICAgICAgKSl9XG4gICAgICAgICAgICA8L2Rpdj5cblxuICAgICAgICAgICAgPEZhZGVJbiBkZWxheT17MC4zfT5cbiAgICAgICAgICAgICAgPG1vdGlvbi5hXG4gICAgICAgICAgICAgICAgaHJlZj17aG9tZS5jb250YWN0LmN0YV91cmx9XG4gICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwiaW5saW5lLWZsZXggaXRlbXMtY2VudGVyIGdhcC0zIHB4LTEwIHB5LTQgZm9udC1zZW1pYm9sZCB0ZXh0LXdoaXRlXCJcbiAgICAgICAgICAgICAgICBzdHlsZT17e1xuICAgICAgICAgICAgICAgICAgYmFja2dyb3VuZDogJ2xpbmVhci1ncmFkaWVudCgxMzVkZWcsICNmZjdhMjYsICNlODQ1MWMpJyxcbiAgICAgICAgICAgICAgICAgIGJvcmRlclJhZGl1czogJzJweCcsXG4gICAgICAgICAgICAgICAgICBmb250U2l6ZTogJzFyZW0nLFxuICAgICAgICAgICAgICAgICAgbGV0dGVyU3BhY2luZzogJzAuMDZlbScsXG4gICAgICAgICAgICAgICAgICBmb250RmFtaWx5OiAndmFyKC0tZm9udC1zYW5zKScsXG4gICAgICAgICAgICAgICAgICBib3hTaGFkb3c6ICcwIDAgMjRweCByZ2JhKDI1NSwgMTIyLCAzOCwgMC4zNSknLFxuICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgd2hpbGVIb3Zlcj17e1xuICAgICAgICAgICAgICAgICAgYm94U2hhZG93OiAnMCAwIDQ4cHggcmdiYSgyNTUsIDEyMiwgMzgsIDAuNjUpJyxcbiAgICAgICAgICAgICAgICAgIHNjYWxlOiAxLjAyLFxuICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgd2hpbGVUYXA9e3sgc2NhbGU6IDAuOTggfX1cbiAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgIHtob21lLmNvbnRhY3QuY3RhX2xhYmVsfVxuICAgICAgICAgICAgICA8L21vdGlvbi5hPlxuICAgICAgICAgICAgPC9GYWRlSW4+XG4gICAgICAgICAgPC9kaXY+XG4gICAgICAgIDwvc2VjdGlvbj5cbiAgICAgIDwvbWFpbj5cbiAgICA8Lz5cbiAgKTtcbn1cbiJdLCJmaWxlIjoiL2FwcC9zcmMvcGFnZXMvaW5kZXgudHN4In0=