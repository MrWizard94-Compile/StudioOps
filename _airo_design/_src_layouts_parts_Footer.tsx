import { createHotContext as __vite__createHotContext } from "/@vite/client";import.meta.hot = __vite__createHotContext("/src/layouts/parts/Footer.tsx");import __vite__cjsImport0_react_jsxDevRuntime from "/node_modules/.vite/deps/react_jsx-dev-runtime.js?v=8d2375ff"; const jsxDEV = __vite__cjsImport0_react_jsxDevRuntime["jsxDEV"];
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
  window.$RefreshReg$ = RefreshRuntime.getRefreshReg("/app/src/layouts/parts/Footer.tsx");
  window.$RefreshSig$ = RefreshRuntime.createSignatureFunctionForTransform;
}
export default function Footer() {
  const currentYear = (/* @__PURE__ */ new Date()).getFullYear();
  return /* @__PURE__ */ jsxDEV(
    "footer",
    {
      style: {
        background: "#0a0706",
        borderTop: "1px solid rgba(255, 122, 38, 0.2)"
      },
      "data-dev-file": "/app/src/layouts/parts/Footer.tsx",
      "data-dev-line": 5,
      "data-dev-id": "42358d",
      children: [
        /* @__PURE__ */ jsxDEV(
          "div",
          {
            style: {
              height: "2px",
              background: "linear-gradient(90deg, transparent, #ff7a26, #e8451c, #ff7a26, transparent)",
              opacity: 0.6
            },
            "data-dev-file": "/app/src/layouts/parts/Footer.tsx",
            "data-dev-line": 12,
            "data-dev-id": "166321"
          },
          void 0,
          false,
          {
            fileName: "/app/src/layouts/parts/Footer.tsx",
            lineNumber: 31,
            columnNumber: 7
          },
          this
        ),
        /* @__PURE__ */ jsxDEV("div", { className: "container mx-auto px-6 py-12", "data-dev-file": "/app/src/layouts/parts/Footer.tsx", "data-dev-line": 20, "data-dev-id": "166322", children: [
          /* @__PURE__ */ jsxDEV("div", { className: "mb-10 max-w-2xl", "data-dev-file": "/app/src/layouts/parts/Footer.tsx", "data-dev-line": 22, "data-dev-id": "3dac76", children: /* @__PURE__ */ jsxDEV(
            "p",
            {
              className: "text-base leading-relaxed",
              style: { color: "rgba(245, 237, 228, 0.65)", fontFamily: "var(--font-sans)" },
              "data-dev-editable": "text",
              "data-dev-file": "/app/src/layouts/parts/Footer.tsx",
              "data-dev-line": 23,
              "data-dev-id": "aed817",
              children: [
                "Made in open collaboration with AI tools; written into shape, directed, and finished by Rob Bulkley.",
                " ",
                /* @__PURE__ */ jsxDEV("span", { style: { color: "#ff7a26", fontStyle: "italic" }, "data-dev-editable": "text", "data-dev-file": "/app/src/layouts/parts/Footer.tsx", "data-dev-line": 28, "data-dev-id": "73b11a", children: "AI is in the name — the wizard is in the work." }, void 0, false, {
                  fileName: "/app/src/layouts/parts/Footer.tsx",
                  lineNumber: 47,
                  columnNumber: 13
                }, this)
              ]
            },
            void 0,
            true,
            {
              fileName: "/app/src/layouts/parts/Footer.tsx",
              lineNumber: 42,
              columnNumber: 11
            },
            this
          ) }, void 0, false, {
            fileName: "/app/src/layouts/parts/Footer.tsx",
            lineNumber: 41,
            columnNumber: 9
          }, this),
          /* @__PURE__ */ jsxDEV("div", { className: "flex flex-col md:flex-row justify-between items-start md:items-center gap-6", "data-dev-file": "/app/src/layouts/parts/Footer.tsx", "data-dev-line": 34, "data-dev-id": "3dac77", children: [
            /* @__PURE__ */ jsxDEV("div", { "data-dev-file": "/app/src/layouts/parts/Footer.tsx", "data-dev-line": 36, "data-dev-id": "0de18b", children: [
              /* @__PURE__ */ jsxDEV(
                "div",
                {
                  className: "text-sm font-semibold mb-1",
                  style: { color: "rgba(245, 237, 228, 0.9)", fontFamily: "var(--font-heading)", letterSpacing: "0.08em" },
                  "data-dev-dynamic": "true",
                  "data-dev-file": "/app/src/layouts/parts/Footer.tsx",
                  "data-dev-line": 37,
                  "data-dev-id": "fe959f",
                  children: [
                    "© ",
                    currentYear,
                    " Wizard Productions AI Studio"
                  ]
                },
                void 0,
                true,
                {
                  fileName: "/app/src/layouts/parts/Footer.tsx",
                  lineNumber: 56,
                  columnNumber: 13
                },
                this
              ),
              /* @__PURE__ */ jsxDEV(
                "div",
                {
                  className: "text-xs",
                  style: { color: "rgba(245, 237, 228, 0.35)", fontFamily: "var(--font-sans)", letterSpacing: "0.05em" },
                  "data-dev-file": "/app/src/layouts/parts/Footer.tsx",
                  "data-dev-line": 43,
                  "data-dev-id": "fe95a0",
                  children: "Forging the future of creative media."
                },
                void 0,
                false,
                {
                  fileName: "/app/src/layouts/parts/Footer.tsx",
                  lineNumber: 62,
                  columnNumber: 13
                },
                this
              )
            ] }, void 0, true, {
              fileName: "/app/src/layouts/parts/Footer.tsx",
              lineNumber: 55,
              columnNumber: 11
            }, this),
            /* @__PURE__ */ jsxDEV("nav", { className: "flex gap-6", "aria-label": "Footer links", "data-dev-dynamic": "true", "data-dev-file": "/app/src/layouts/parts/Footer.tsx", "data-dev-line": 52, "data-dev-id": "be738d", children: [
              { label: "Storefront", href: "https://wpaistudio.gumroad.com", external: true },
              { label: "GitHub", href: "https://github.com/MrWizard94-Compile", external: true },
              { label: "Contact", href: "mailto:rob@wpaistudio.net", external: true }
            ].map(
              (link) => /* @__PURE__ */ jsxDEV(
                "a",
                {
                  href: link.href,
                  target: link.external ? "_blank" : void 0,
                  rel: link.external ? "noopener noreferrer" : void 0,
                  className: "text-xs transition-colors duration-200",
                  style: { color: "rgba(245, 237, 228, 0.4)", letterSpacing: "0.05em" },
                  onMouseEnter: (e) => e.currentTarget.style.color = "#ff7a26",
                  onMouseLeave: (e) => e.currentTarget.style.color = "rgba(245, 237, 228, 0.4)",
                  "data-dev-dynamic": "true",
                  "data-dev-file": "/app/src/layouts/parts/Footer.tsx",
                  "data-dev-line": 58,
                  "data-dev-id": "db12df",
                  children: link.label
                },
                link.label,
                false,
                {
                  fileName: "/app/src/layouts/parts/Footer.tsx",
                  lineNumber: 77,
                  columnNumber: 13
                },
                this
              )
            ) }, void 0, false, {
              fileName: "/app/src/layouts/parts/Footer.tsx",
              lineNumber: 71,
              columnNumber: 11
            }, this)
          ] }, void 0, true, {
            fileName: "/app/src/layouts/parts/Footer.tsx",
            lineNumber: 53,
            columnNumber: 9
          }, this)
        ] }, void 0, true, {
          fileName: "/app/src/layouts/parts/Footer.tsx",
          lineNumber: 39,
          columnNumber: 7
        }, this)
      ]
    },
    void 0,
    true,
    {
      fileName: "/app/src/layouts/parts/Footer.tsx",
      lineNumber: 24,
      columnNumber: 5
    },
    this
  );
}
_c = Footer;
var _c;
$RefreshReg$(_c, "Footer");
if (import.meta.hot && !inWebWorker) {
  window.$RefreshReg$ = prevRefreshReg;
  window.$RefreshSig$ = prevRefreshSig;
}
if (import.meta.hot && !inWebWorker) {
  RefreshRuntime.__hmr_import(import.meta.url).then((currentExports) => {
    RefreshRuntime.registerExportsForReactRefresh("/app/src/layouts/parts/Footer.tsx", currentExports);
    import.meta.hot.accept((nextExports) => {
      if (!nextExports) return;
      const invalidateMessage = RefreshRuntime.validateRefreshBoundaryAndEnqueueUpdate("/app/src/layouts/parts/Footer.tsx", currentExports, nextExports);
      if (invalidateMessage) import.meta.hot.invalidate(invalidateMessage);
    });
  });
}

//# sourceMappingURL=data:application/json;base64,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WixRQUFRO0FBQUEsa0JBQTRCO0FBQUE7QUFBQTtBQUFBO0FBQUEsa0JBRWhHUSxlQUFLSjtBQUFBQTtBQUFBQSxnQkFUREksS0FBS0o7QUFBQUEsZ0JBRFo7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUE7QUFBQSxjQVdBO0FBQUEsWUFDRCxLQWxCSDtBQUFBO0FBQUE7QUFBQTtBQUFBLG1CQW1CQTtBQUFBLGVBckNGO0FBQUE7QUFBQTtBQUFBO0FBQUEsaUJBc0NBO0FBQUEsYUFwREY7QUFBQTtBQUFBO0FBQUE7QUFBQSxlQXFEQTtBQUFBO0FBQUE7QUFBQSxJQXBFRjtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUEsRUFxRUE7QUFFSjtBQUFDUyxLQTNFdUJyQjtBQUFNLElBQUFxQjtBQUFBLGFBQUFBLElBQUEiLCJuYW1lcyI6WyJGb290ZXIiLCJjdXJyZW50WWVhciIsIkRhdGUiLCJnZXRGdWxsWWVhciIsImJhY2tncm91bmQiLCJib3JkZXJUb3AiLCJoZWlnaHQiLCJvcGFjaXR5IiwiY29sb3IiLCJmb250RmFtaWx5IiwiZm9udFN0eWxlIiwibGV0dGVyU3BhY2luZyIsImxhYmVsIiwiaHJlZiIsImV4dGVybmFsIiwibWFwIiwibGluayIsInVuZGVmaW5lZCIsImUiLCJjdXJyZW50VGFyZ2V0Iiwic3R5bGUiLCJfYyJdLCJpZ25vcmVMaXN0IjpbXSwic291cmNlcyI6WyJGb290ZXIudHN4Il0sInNvdXJjZXNDb250ZW50IjpbImV4cG9ydCBkZWZhdWx0IGZ1bmN0aW9uIEZvb3RlcigpIHtcbiAgY29uc3QgY3VycmVudFllYXIgPSBuZXcgRGF0ZSgpLmdldEZ1bGxZZWFyKCk7XG5cbiAgcmV0dXJuIChcbiAgICA8Zm9vdGVyXG4gICAgICBzdHlsZT17e1xuICAgICAgICBiYWNrZ3JvdW5kOiAnIzBhMDcwNicsXG4gICAgICAgIGJvcmRlclRvcDogJzFweCBzb2xpZCByZ2JhKDI1NSwgMTIyLCAzOCwgMC4yKScsXG4gICAgICB9fVxuICAgID5cbiAgICAgIHsvKiBFbWJlciBkaXZpZGVyIGxpbmUgKi99XG4gICAgICA8ZGl2XG4gICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgaGVpZ2h0OiAnMnB4JyxcbiAgICAgICAgICBiYWNrZ3JvdW5kOiAnbGluZWFyLWdyYWRpZW50KDkwZGVnLCB0cmFuc3BhcmVudCwgI2ZmN2EyNiwgI2U4NDUxYywgI2ZmN2EyNiwgdHJhbnNwYXJlbnQpJyxcbiAgICAgICAgICBvcGFjaXR5OiAwLjYsXG4gICAgICAgIH19XG4gICAgICAvPlxuXG4gICAgICA8ZGl2IGNsYXNzTmFtZT1cImNvbnRhaW5lciBteC1hdXRvIHB4LTYgcHktMTJcIj5cbiAgICAgICAgey8qIEFJIERpc2Nsb3N1cmUg4oCUIGJyYW5kIHN0YXRlbWVudCwgbm90IGZpbmUgcHJpbnQgKi99XG4gICAgICAgIDxkaXYgY2xhc3NOYW1lPVwibWItMTAgbWF4LXctMnhsXCI+XG4gICAgICAgICAgPHBcbiAgICAgICAgICAgIGNsYXNzTmFtZT1cInRleHQtYmFzZSBsZWFkaW5nLXJlbGF4ZWRcIlxuICAgICAgICAgICAgc3R5bGU9e3sgY29sb3I6ICdyZ2JhKDI0NSwgMjM3LCAyMjgsIDAuNjUpJywgZm9udEZhbWlseTogJ3ZhcigtLWZvbnQtc2FucyknIH19XG4gICAgICAgICAgPlxuICAgICAgICAgICAgTWFkZSBpbiBvcGVuIGNvbGxhYm9yYXRpb24gd2l0aCBBSSB0b29sczsgd3JpdHRlbiBpbnRvIHNoYXBlLCBkaXJlY3RlZCwgYW5kIGZpbmlzaGVkIGJ5IFJvYiBCdWxrbGV5LnsnICd9XG4gICAgICAgICAgICA8c3BhbiBzdHlsZT17eyBjb2xvcjogJyNmZjdhMjYnLCBmb250U3R5bGU6ICdpdGFsaWMnIH19PlxuICAgICAgICAgICAgICBBSSBpcyBpbiB0aGUgbmFtZSDigJQgdGhlIHdpemFyZCBpcyBpbiB0aGUgd29yay5cbiAgICAgICAgICAgIDwvc3Bhbj5cbiAgICAgICAgICA8L3A+XG4gICAgICAgIDwvZGl2PlxuXG4gICAgICAgIDxkaXYgY2xhc3NOYW1lPVwiZmxleCBmbGV4LWNvbCBtZDpmbGV4LXJvdyBqdXN0aWZ5LWJldHdlZW4gaXRlbXMtc3RhcnQgbWQ6aXRlbXMtY2VudGVyIGdhcC02XCI+XG4gICAgICAgICAgey8qIEJyYW5kICovfVxuICAgICAgICAgIDxkaXY+XG4gICAgICAgICAgICA8ZGl2XG4gICAgICAgICAgICAgIGNsYXNzTmFtZT1cInRleHQtc20gZm9udC1zZW1pYm9sZCBtYi0xXCJcbiAgICAgICAgICAgICAgc3R5bGU9e3sgY29sb3I6ICdyZ2JhKDI0NSwgMjM3LCAyMjgsIDAuOSknLCBmb250RmFtaWx5OiAndmFyKC0tZm9udC1oZWFkaW5nKScsIGxldHRlclNwYWNpbmc6ICcwLjA4ZW0nIH19XG4gICAgICAgICAgICA+XG4gICAgICAgICAgICAgIMKpIHtjdXJyZW50WWVhcn0gV2l6YXJkIFByb2R1Y3Rpb25zIEFJIFN0dWRpb1xuICAgICAgICAgICAgPC9kaXY+XG4gICAgICAgICAgICA8ZGl2XG4gICAgICAgICAgICAgIGNsYXNzTmFtZT1cInRleHQteHNcIlxuICAgICAgICAgICAgICBzdHlsZT17eyBjb2xvcjogJ3JnYmEoMjQ1LCAyMzcsIDIyOCwgMC4zNSknLCBmb250RmFtaWx5OiAndmFyKC0tZm9udC1zYW5zKScsIGxldHRlclNwYWNpbmc6ICcwLjA1ZW0nIH19XG4gICAgICAgICAgICA+XG4gICAgICAgICAgICAgIEZvcmdpbmcgdGhlIGZ1dHVyZSBvZiBjcmVhdGl2ZSBtZWRpYS5cbiAgICAgICAgICAgIDwvZGl2PlxuICAgICAgICAgIDwvZGl2PlxuXG4gICAgICAgICAgey8qIExpbmtzICovfVxuICAgICAgICAgIDxuYXYgY2xhc3NOYW1lPVwiZmxleCBnYXAtNlwiIGFyaWEtbGFiZWw9XCJGb290ZXIgbGlua3NcIj5cbiAgICAgICAgICAgIHtbXG4gICAgICAgICAgICAgIHsgbGFiZWw6ICdTdG9yZWZyb250JywgaHJlZjogJ2h0dHBzOi8vd3BhaXN0dWRpby5ndW1yb2FkLmNvbScsIGV4dGVybmFsOiB0cnVlIH0sXG4gICAgICAgICAgICAgIHsgbGFiZWw6ICdHaXRIdWInLCBocmVmOiAnaHR0cHM6Ly9naXRodWIuY29tL01yV2l6YXJkOTQtQ29tcGlsZScsIGV4dGVybmFsOiB0cnVlIH0sXG4gICAgICAgICAgICAgIHsgbGFiZWw6ICdDb250YWN0JywgaHJlZjogJ21haWx0bzpyb2JAd3BhaXN0dWRpby5uZXQnLCBleHRlcm5hbDogdHJ1ZSB9LFxuICAgICAgICAgICAgXS5tYXAoKGxpbmspID0+IChcbiAgICAgICAgICAgICAgPGFcbiAgICAgICAgICAgICAgICBrZXk9e2xpbmsubGFiZWx9XG4gICAgICAgICAgICAgICAgaHJlZj17bGluay5ocmVmfVxuICAgICAgICAgICAgICAgIHRhcmdldD17bGluay5leHRlcm5hbCA/ICdfYmxhbmsnIDogdW5kZWZpbmVkfVxuICAgICAgICAgICAgICAgIHJlbD17bGluay5leHRlcm5hbCA/ICdub29wZW5lciBub3JlZmVycmVyJyA6IHVuZGVmaW5lZH1cbiAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJ0ZXh0LXhzIHRyYW5zaXRpb24tY29sb3JzIGR1cmF0aW9uLTIwMFwiXG4gICAgICAgICAgICAgICAgc3R5bGU9e3sgY29sb3I6ICdyZ2JhKDI0NSwgMjM3LCAyMjgsIDAuNCknLCBsZXR0ZXJTcGFjaW5nOiAnMC4wNWVtJyB9fVxuICAgICAgICAgICAgICAgIG9uTW91c2VFbnRlcj17KGUpID0+ICgoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5jb2xvciA9ICcjZmY3YTI2Jyl9XG4gICAgICAgICAgICAgICAgb25Nb3VzZUxlYXZlPXsoZSkgPT4gKChlLmN1cnJlbnRUYXJnZXQgYXMgSFRNTEVsZW1lbnQpLnN0eWxlLmNvbG9yID0gJ3JnYmEoMjQ1LCAyMzcsIDIyOCwgMC40KScpfVxuICAgICAgICAgICAgICA+XG4gICAgICAgICAgICAgICAge2xpbmsubGFiZWx9XG4gICAgICAgICAgICAgIDwvYT5cbiAgICAgICAgICAgICkpfVxuICAgICAgICAgIDwvbmF2PlxuICAgICAgICA8L2Rpdj5cbiAgICAgIDwvZGl2PlxuICAgIDwvZm9vdGVyPlxuICApO1xufVxuIl0sImZpbGUiOiIvYXBwL3NyYy9sYXlvdXRzL3BhcnRzL0Zvb3Rlci50c3gifQ==