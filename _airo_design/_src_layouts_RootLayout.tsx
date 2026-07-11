import { createHotContext as __vite__createHotContext } from "/@vite/client";import.meta.hot = __vite__createHotContext("/src/layouts/RootLayout.tsx");import __vite__cjsImport0_react_jsxDevRuntime from "/node_modules/.vite/deps/react_jsx-dev-runtime.js?v=38c95354"; const jsxDEV = __vite__cjsImport0_react_jsxDevRuntime["jsxDEV"];
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
  window.$RefreshReg$ = RefreshRuntime.getRefreshReg("/app/src/layouts/RootLayout.tsx");
  window.$RefreshSig$ = RefreshRuntime.createSignatureFunctionForTransform;
}
import { Helmet } from "/node_modules/.vite/deps/@dr__pogodin_react-helmet.js?v=38c95354";
import { ScrollRestoration } from "/node_modules/.vite/deps/react-router-dom.js?v=38c95354";
import Footer from "/src/layouts/parts/Footer.tsx";
import Header from "/src/layouts/parts/Header.tsx";
import Website from "/src/layouts/Website.tsx";
export default function RootLayout({ children }) {
  return /* @__PURE__ */ jsxDEV(Website, { "data-dev-file": "/app/src/layouts/RootLayout.tsx", "data-dev-line": 24, "data-dev-id": "7d9a0b", children: [
    /* @__PURE__ */ jsxDEV(Helmet, { "data-dev-file": "/app/src/layouts/RootLayout.tsx", "data-dev-line": 25, "data-dev-id": "1b335b", children: [
      /* @__PURE__ */ jsxDEV("title", { "data-dev-file": "/app/src/layouts/RootLayout.tsx", "data-dev-line": 26, "data-dev-id": "8d240e", children: "Wizard Productions AI Studio — Forging the future of creative media" }, void 0, false, {
        fileName: "/app/src/layouts/RootLayout.tsx",
        lineNumber: 45,
        columnNumber: 9
      }, this),
      /* @__PURE__ */ jsxDEV("meta", { name: "description", content: "WPAI: AI creative studio shipping heavy music, developer tools, games, and AI research. Human-directed, AI-assisted.", "data-dev-file": "/app/src/layouts/RootLayout.tsx", "data-dev-line": 27, "data-dev-id": "cc6a73" }, void 0, false, {
        fileName: "/app/src/layouts/RootLayout.tsx",
        lineNumber: 46,
        columnNumber: 9
      }, this)
    ] }, void 0, true, {
      fileName: "/app/src/layouts/RootLayout.tsx",
      lineNumber: 44,
      columnNumber: 7
    }, this),
    /* @__PURE__ */ jsxDEV(ScrollRestoration, { "data-dev-file": "/app/src/layouts/RootLayout.tsx", "data-dev-line": 29, "data-dev-id": "a1b045" }, void 0, false, {
      fileName: "/app/src/layouts/RootLayout.tsx",
      lineNumber: 48,
      columnNumber: 7
    }, this),
    /* @__PURE__ */ jsxDEV(Header, { "data-dev-file": "/app/src/layouts/RootLayout.tsx", "data-dev-line": 30, "data-dev-id": "cf8f65" }, void 0, false, {
      fileName: "/app/src/layouts/RootLayout.tsx",
      lineNumber: 49,
      columnNumber: 7
    }, this),
    children,
    /* @__PURE__ */ jsxDEV(Footer, { "data-dev-file": "/app/src/layouts/RootLayout.tsx", "data-dev-line": 32, "data-dev-id": "dc060b" }, void 0, false, {
      fileName: "/app/src/layouts/RootLayout.tsx",
      lineNumber: 51,
      columnNumber: 7
    }, this)
  ] }, void 0, true, {
    fileName: "/app/src/layouts/RootLayout.tsx",
    lineNumber: 43,
    columnNumber: 5
  }, this);
}
_c = RootLayout;
var _c;
$RefreshReg$(_c, "RootLayout");
if (import.meta.hot && !inWebWorker) {
  window.$RefreshReg$ = prevRefreshReg;
  window.$RefreshSig$ = prevRefreshSig;
}
if (import.meta.hot && !inWebWorker) {
  RefreshRuntime.__hmr_import(import.meta.url).then((currentExports) => {
    RefreshRuntime.registerExportsForReactRefresh("/app/src/layouts/RootLayout.tsx", currentExports);
    import.meta.hot.accept((nextExports) => {
      if (!nextExports) return;
      const invalidateMessage = RefreshRuntime.validateRefreshBoundaryAndEnqueueUpdate("/app/src/layouts/RootLayout.tsx", currentExports, nextExports);
      if (invalidateMessage) import.meta.hot.invalidate(invalidateMessage);
    });
  });
}

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJtYXBwaW5ncyI6IkFBeUJROzs7Ozs7Ozs7Ozs7Ozs7O0FBekJSLFNBQVNBLGNBQWM7QUFFdkIsU0FBU0MseUJBQXlCO0FBRWxDLE9BQU9DLFlBQVk7QUFDbkIsT0FBT0MsWUFBWTtBQUNuQixPQUFPQyxhQUFhO0FBZXBCLHdCQUF3QkMsV0FBVyxFQUFFQyxTQUEwQixHQUFHO0FBQ2hFLFNBQ0UsdUJBQUMsV0FBTyxrR0FDTjtBQUFBLDJCQUFDLFVBQU0sa0dBQ0w7QUFBQSw2QkFBQyxXQUFLLGtHQUFDLG1GQUFQO0FBQUE7QUFBQTtBQUFBO0FBQUEsYUFBMEU7QUFBQSxNQUMxRSx1QkFBQyxVQUFLLE1BQUssZUFBYyxTQUFRLHdIQUFzSCxvR0FBdko7QUFBQTtBQUFBO0FBQUE7QUFBQSxhQUF1SjtBQUFBLFNBRnpKO0FBQUE7QUFBQTtBQUFBO0FBQUEsV0FHQTtBQUFBLElBQ0EsdUJBQUMscUJBQWlCLG9HQUFsQjtBQUFBO0FBQUE7QUFBQTtBQUFBLFdBQWtCO0FBQUEsSUFDbEIsdUJBQUMsVUFBTSxvR0FBUDtBQUFBO0FBQUE7QUFBQTtBQUFBLFdBQU87QUFBQSxJQUNOQTtBQUFBQSxJQUNELHVCQUFDLFVBQU0sb0dBQVA7QUFBQTtBQUFBO0FBQUE7QUFBQSxXQUFPO0FBQUEsT0FSVDtBQUFBO0FBQUE7QUFBQTtBQUFBLFNBU0E7QUFFSjtBQUFDQyxLQWJ1QkY7QUFBVSxJQUFBRTtBQUFBLGFBQUFBLElBQUEiLCJuYW1lcyI6WyJIZWxtZXQiLCJTY3JvbGxSZXN0b3JhdGlvbiIsIkZvb3RlciIsIkhlYWRlciIsIldlYnNpdGUiLCJSb290TGF5b3V0IiwiY2hpbGRyZW4iLCJfYyJdLCJpZ25vcmVMaXN0IjpbXSwic291cmNlcyI6WyJSb290TGF5b3V0LnRzeCJdLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyBIZWxtZXQgfSBmcm9tICdAZHIucG9nb2Rpbi9yZWFjdC1oZWxtZXQnO1xuaW1wb3J0IHsgdHlwZSBSZWFjdEVsZW1lbnQgfSBmcm9tICdyZWFjdCc7XG5pbXBvcnQgeyBTY3JvbGxSZXN0b3JhdGlvbiB9IGZyb20gJ3JlYWN0LXJvdXRlci1kb20nO1xuXG5pbXBvcnQgRm9vdGVyIGZyb20gJ0AvbGF5b3V0cy9wYXJ0cy9Gb290ZXInO1xuaW1wb3J0IEhlYWRlciBmcm9tICdAL2xheW91dHMvcGFydHMvSGVhZGVyJztcbmltcG9ydCBXZWJzaXRlIGZyb20gJ0AvbGF5b3V0cy9XZWJzaXRlJztcblxuLyoqXG4gKiBSb290IGxheW91dCBjb21wb25lbnQgdGhhdCB3cmFwcyBhbGwgcGFnZXMgd2l0aCBjb25zaXN0ZW50IGhlYWRlciBhbmQgZm9vdGVyLlxuICpcbiAqIFRvIGN1c3RvbWl6ZSB0aGUgaGVhZGVyIG9yIGZvb3RlciwgZGlyZWN0bHkgZWRpdCB0aGUgSGVhZGVyLnRzeCBhbmQgRm9vdGVyLnRzeFxuICogZmlsZXMgaW4gdGhlIGxheW91dHMvcGFydHMgZGlyZWN0b3J5LlxuICpcbiAqIFNpdGUtd2lkZSA8dGl0bGU+IGFuZCA8bWV0YT4gbGl2ZSBpbiB0aGUgPEhlbG1ldD4gYmVsb3cuIEluZGl2aWR1YWwgcGFnZXMgY2FuXG4gKiBvdmVycmlkZSB0aGVtIGJ5IHJlbmRlcmluZyB0aGVpciBvd24gPEhlbG1ldD4g4oCUIGxhc3QtbW91bnRlZCB3aW5zLlxuICovXG5pbnRlcmZhY2UgUm9vdExheW91dFByb3BzIHtcbiAgY2hpbGRyZW46IFJlYWN0RWxlbWVudDtcbn1cblxuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gUm9vdExheW91dCh7IGNoaWxkcmVuIH06IFJvb3RMYXlvdXRQcm9wcykge1xuICByZXR1cm4gKFxuICAgIDxXZWJzaXRlPlxuICAgICAgPEhlbG1ldD5cbiAgICAgICAgPHRpdGxlPldpemFyZCBQcm9kdWN0aW9ucyBBSSBTdHVkaW8g4oCUIEZvcmdpbmcgdGhlIGZ1dHVyZSBvZiBjcmVhdGl2ZSBtZWRpYTwvdGl0bGU+XG4gICAgICAgIDxtZXRhIG5hbWU9XCJkZXNjcmlwdGlvblwiIGNvbnRlbnQ9XCJXUEFJOiBBSSBjcmVhdGl2ZSBzdHVkaW8gc2hpcHBpbmcgaGVhdnkgbXVzaWMsIGRldmVsb3BlciB0b29scywgZ2FtZXMsIGFuZCBBSSByZXNlYXJjaC4gSHVtYW4tZGlyZWN0ZWQsIEFJLWFzc2lzdGVkLlwiIC8+XG4gICAgICA8L0hlbG1ldD5cbiAgICAgIDxTY3JvbGxSZXN0b3JhdGlvbiAvPlxuICAgICAgPEhlYWRlciAvPlxuICAgICAge2NoaWxkcmVufVxuICAgICAgPEZvb3RlciAvPlxuICAgIDwvV2Vic2l0ZT5cbiAgKTtcbn1cbiJdLCJmaWxlIjoiL2FwcC9zcmMvbGF5b3V0cy9Sb290TGF5b3V0LnRzeCJ9