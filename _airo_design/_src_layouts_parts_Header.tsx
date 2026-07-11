import { createHotContext as __vite__createHotContext } from "/@vite/client";import.meta.hot = __vite__createHotContext("/src/layouts/parts/Header.tsx");import __vite__cjsImport0_react_jsxDevRuntime from "/node_modules/.vite/deps/react_jsx-dev-runtime.js?v=8d2375ff"; const jsxDEV = __vite__cjsImport0_react_jsxDevRuntime["jsxDEV"];
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
  window.$RefreshReg$ = RefreshRuntime.getRefreshReg("/app/src/layouts/parts/Header.tsx");
  window.$RefreshSig$ = RefreshRuntime.createSignatureFunctionForTransform;
}
var _s = $RefreshSig$();
import { FormattedBoundText } from "/src/components/FormattedBoundText.tsx";
import { Link } from "/node_modules/.vite/deps/react-router-dom.js?v=8d2375ff";
import { Menu, X } from "/node_modules/.vite/deps/lucide-react.js?v=8d2375ff";
import __vite__cjsImport6_react from "/node_modules/.vite/deps/react.js?v=8d2375ff"; const useState = __vite__cjsImport6_react["useState"]; const useEffect = __vite__cjsImport6_react["useEffect"];
export default function Header() {
  _s();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);
  const navItems = [
    { href: "/products", label: "Products", isRoute: true },
    { href: "/studio", label: "Studio", isRoute: true },
    { href: "/about", label: "About", isRoute: true },
    { href: "/contact", label: "Contact", isRoute: true }
  ];
  const handleNavClick = (href) => {
    setIsMobileMenuOpen(false);
    if (href.startsWith("#")) {
      const el = document.querySelector(href);
      if (el) el.scrollIntoView({ behavior: "smooth" });
    }
  };
  return /* @__PURE__ */ jsxDEV(
    "header",
    {
      className: "sticky top-0 z-50 transition-all duration-300",
      style: {
        background: scrolled ? "rgba(10, 7, 6, 0.97)" : "rgba(10, 7, 6, 0.85)",
        backdropFilter: "blur(12px)",
        borderBottom: scrolled ? "1px solid rgba(255, 122, 38, 0.15)" : "1px solid transparent"
      },
      "data-dev-file": "/app/src/layouts/parts/Header.tsx",
      "data-dev-line": 31,
      "data-dev-id": "d07c01",
      children: /* @__PURE__ */ jsxDEV("div", { className: "container mx-auto px-6", "data-dev-dynamic": "true", "data-dev-file": "/app/src/layouts/parts/Header.tsx", "data-dev-line": 41, "data-dev-id": "24b095", children: [
        /* @__PURE__ */ jsxDEV("div", { className: "flex h-20 items-center justify-between", "data-dev-file": "/app/src/layouts/parts/Header.tsx", "data-dev-line": 42, "data-dev-id": "7b0429", children: [
          /* @__PURE__ */ jsxDEV(Link, { to: "/", className: "flex items-center shrink-0", "data-dev-file": "/app/src/layouts/parts/Header.tsx", "data-dev-line": 44, "data-dev-id": "868d08", children: /* @__PURE__ */ jsxDEV(
            "img",
            {
              src: "/airo-assets/images/logo/horizontal",
              alt: "Wizard Productions AI Studio",
              className: "h-10 w-auto object-contain shrink-0",
              "data-dev-file": "/app/src/layouts/parts/Header.tsx",
              "data-dev-line": 45,
              "data-dev-id": "979716"
            },
            void 0,
            false,
            {
              fileName: "/app/src/layouts/parts/Header.tsx",
              lineNumber: 64,
              columnNumber: 13
            },
            this
          ) }, void 0, false, {
            fileName: "/app/src/layouts/parts/Header.tsx",
            lineNumber: 63,
            columnNumber: 11
          }, this),
          /* @__PURE__ */ jsxDEV("nav", { className: "hidden md:flex items-center gap-8", "aria-label": "Main navigation", "data-dev-dynamic": "true", "data-dev-file": "/app/src/layouts/parts/Header.tsx", "data-dev-line": 53, "data-dev-id": "5f48bf", children: [
            navItems.map(
              (item) => item.isRoute ? /* @__PURE__ */ jsxDEV(
                Link,
                {
                  to: item.href,
                  className: "text-sm font-medium tracking-wide transition-colors duration-200",
                  style: {
                    color: "rgba(245, 237, 228, 0.7)",
                    fontFamily: "var(--font-sans)",
                    letterSpacing: "0.05em"
                  },
                  onMouseEnter: (e) => e.currentTarget.style.color = "#ff7a26",
                  onMouseLeave: (e) => e.currentTarget.style.color = "rgba(245, 237, 228, 0.7)",
                  "data-dev-conformable-array": "navItems",
                  "data-dev-conformable-page": "src/layouts/parts/Header.tsx",
                  "data-dev-conformable-id": "L15C8",
                  "data-dev-dynamic": "true",
                  "data-dev-file": "/app/src/layouts/parts/Header.tsx",
                  "data-dev-line": 56,
                  "data-dev-id": "090cde",
                  children: item.label
                },
                item.href,
                false,
                {
                  fileName: "/app/src/layouts/parts/Header.tsx",
                  lineNumber: 75,
                  columnNumber: 13
                },
                this
              ) : /* @__PURE__ */ jsxDEV(
                "button",
                {
                  onClick: () => handleNavClick(item.href),
                  className: "text-sm font-medium tracking-wide transition-colors duration-200 cursor-pointer",
                  style: {
                    color: "rgba(245, 237, 228, 0.7)",
                    fontFamily: "var(--font-sans)",
                    letterSpacing: "0.05em"
                  },
                  onMouseEnter: (e) => e.currentTarget.style.color = "#ff7a26",
                  onMouseLeave: (e) => e.currentTarget.style.color = "rgba(245, 237, 228, 0.7)",
                  "data-dev-conformable-array": "navItems",
                  "data-dev-conformable-page": "src/layouts/parts/Header.tsx",
                  "data-dev-conformable-id": "L15C8",
                  "data-dev-dynamic": "true",
                  "data-dev-file": "/app/src/layouts/parts/Header.tsx",
                  "data-dev-line": 71,
                  "data-dev-id": "af6a4c",
                  children: item.label
                },
                item.href,
                false,
                {
                  fileName: "/app/src/layouts/parts/Header.tsx",
                  lineNumber: 90,
                  columnNumber: 13
                },
                this
              )
            ),
            /* @__PURE__ */ jsxDEV(
              "a",
              {
                href: "https://wpaistudio.gumroad.com",
                target: "_blank",
                rel: "noopener noreferrer",
                className: "text-sm font-semibold px-5 py-2 transition-all duration-200",
                style: {
                  background: "linear-gradient(135deg, #ff7a26, #e8451c)",
                  color: "#fff",
                  borderRadius: "2px",
                  letterSpacing: "0.06em",
                  fontFamily: "var(--font-sans)",
                  boxShadow: "0 0 16px rgba(255, 122, 38, 0.3)"
                },
                onMouseEnter: (e) => {
                  e.currentTarget.style.boxShadow = "0 0 28px rgba(255, 122, 38, 0.55)";
                },
                onMouseLeave: (e) => {
                  e.currentTarget.style.boxShadow = "0 0 16px rgba(255, 122, 38, 0.3)";
                },
                "data-dev-editable": "text",
                "data-dev-file": "/app/src/layouts/parts/Header.tsx",
                "data-dev-line": 87,
                "data-dev-id": "673111",
                children: "Storefront"
              },
              void 0,
              false,
              {
                fileName: "/app/src/layouts/parts/Header.tsx",
                lineNumber: 106,
                columnNumber: 13
              },
              this
            )
          ] }, void 0, true, {
            fileName: "/app/src/layouts/parts/Header.tsx",
            lineNumber: 72,
            columnNumber: 11
          }, this),
          /* @__PURE__ */ jsxDEV(
            "button",
            {
              onClick: () => setIsMobileMenuOpen(!isMobileMenuOpen),
              className: "md:hidden p-2 rounded transition-colors",
              style: { color: "#ff7a26" },
              "aria-label": "Toggle menu",
              "data-dev-dynamic": "true",
              "data-dev-bound-text": "true",
              "data-dev-bound-source-kind": "bound-expression",
              "data-dev-bound-expression-hash": "sha256:b3e78efccf3741859addf847ccd3401fcd474b190bd3f98661200b4087eafc38",
              "data-dev-file": "/app/src/layouts/parts/Header.tsx",
              "data-dev-line": 112,
              "data-dev-id": "8d9cf6",
              children: /* @__PURE__ */ jsxDEV(FormattedBoundText, { devId: "8d9cf6", guard: { file: "src/layouts/parts/Header.tsx", tagName: "button", sourceKind: "bound-expression", contentKey: null, contentKeyTemplate: null, expressionHash: "sha256:b3e78efccf3741859addf847ccd3401fcd474b190bd3f98661200b4087eafc38" }, children: isMobileMenuOpen ? /* @__PURE__ */ jsxDEV(X, { size: 22, "data-dev-file": "/app/src/layouts/parts/Header.tsx", "data-dev-line": 118, "data-dev-id": "ee9cb3" }, void 0, false, {
                fileName: "/app/src/layouts/parts/Header.tsx",
                lineNumber: 137,
                columnNumber: 303
              }, this) : /* @__PURE__ */ jsxDEV(Menu, { size: 22, "data-dev-file": "/app/src/layouts/parts/Header.tsx", "data-dev-line": 118, "data-dev-id": "40cc10" }, void 0, false, {
                fileName: "/app/src/layouts/parts/Header.tsx",
                lineNumber: 137,
                columnNumber: 412
              }, this) }, void 0, false, {
                fileName: "/app/src/layouts/parts/Header.tsx",
                lineNumber: 137,
                columnNumber: 13
              }, this)
            },
            void 0,
            false,
            {
              fileName: "/app/src/layouts/parts/Header.tsx",
              lineNumber: 131,
              columnNumber: 11
            },
            this
          )
        ] }, void 0, true, {
          fileName: "/app/src/layouts/parts/Header.tsx",
          lineNumber: 61,
          columnNumber: 9
        }, this),
        isMobileMenuOpen && /* @__PURE__ */ jsxDEV(
          "div",
          {
            className: "md:hidden py-4 border-t",
            style: { borderColor: "rgba(255, 122, 38, 0.15)" },
            "data-dev-file": "/app/src/layouts/parts/Header.tsx",
            "data-dev-line": 124,
            "data-dev-id": "7b042a",
            children: /* @__PURE__ */ jsxDEV("nav", { className: "flex flex-col gap-1", "aria-label": "Mobile navigation", "data-dev-dynamic": "true", "data-dev-file": "/app/src/layouts/parts/Header.tsx", "data-dev-line": 128, "data-dev-id": "598580", children: [
              navItems.map(
                (item) => item.isRoute ? /* @__PURE__ */ jsxDEV(
                  Link,
                  {
                    to: item.href,
                    className: "text-sm font-medium py-3 px-2 transition-colors duration-200",
                    style: { color: "rgba(245, 237, 228, 0.75)", fontFamily: "var(--font-sans)" },
                    onClick: () => setIsMobileMenuOpen(false),
                    "data-dev-conformable-array": "navItems",
                    "data-dev-conformable-page": "src/layouts/parts/Header.tsx",
                    "data-dev-conformable-id": "L15C8",
                    "data-dev-dynamic": "true",
                    "data-dev-file": "/app/src/layouts/parts/Header.tsx",
                    "data-dev-line": 131,
                    "data-dev-id": "49467f",
                    children: item.label
                  },
                  item.href,
                  false,
                  {
                    fileName: "/app/src/layouts/parts/Header.tsx",
                    lineNumber: 150,
                    columnNumber: 13
                  },
                  this
                ) : /* @__PURE__ */ jsxDEV(
                  "button",
                  {
                    onClick: () => handleNavClick(item.href),
                    className: "text-sm font-medium py-3 px-2 text-left transition-colors duration-200 cursor-pointer",
                    style: { color: "rgba(245, 237, 228, 0.75)", fontFamily: "var(--font-sans)" },
                    "data-dev-conformable-array": "navItems",
                    "data-dev-conformable-page": "src/layouts/parts/Header.tsx",
                    "data-dev-conformable-id": "L15C8",
                    "data-dev-dynamic": "true",
                    "data-dev-file": "/app/src/layouts/parts/Header.tsx",
                    "data-dev-line": 141,
                    "data-dev-id": "e4902d",
                    children: item.label
                  },
                  item.href,
                  false,
                  {
                    fileName: "/app/src/layouts/parts/Header.tsx",
                    lineNumber: 160,
                    columnNumber: 13
                  },
                  this
                )
              ),
              /* @__PURE__ */ jsxDEV(
                "a",
                {
                  href: "https://wpaistudio.gumroad.com",
                  target: "_blank",
                  rel: "noopener noreferrer",
                  className: "mt-3 text-sm font-semibold px-4 py-3 text-center",
                  style: {
                    background: "linear-gradient(135deg, #ff7a26, #e8451c)",
                    color: "#fff",
                    borderRadius: "2px"
                  },
                  "data-dev-editable": "text",
                  "data-dev-file": "/app/src/layouts/parts/Header.tsx",
                  "data-dev-line": 151,
                  "data-dev-id": "c3e652",
                  children: "Storefront"
                },
                void 0,
                false,
                {
                  fileName: "/app/src/layouts/parts/Header.tsx",
                  lineNumber: 170,
                  columnNumber: 15
                },
                this
              )
            ] }, void 0, true, {
              fileName: "/app/src/layouts/parts/Header.tsx",
              lineNumber: 147,
              columnNumber: 13
            }, this)
          },
          void 0,
          false,
          {
            fileName: "/app/src/layouts/parts/Header.tsx",
            lineNumber: 143,
            columnNumber: 9
          },
          this
        )
      ] }, void 0, true, {
        fileName: "/app/src/layouts/parts/Header.tsx",
        lineNumber: 60,
        columnNumber: 7
      }, this)
    },
    void 0,
    false,
    {
      fileName: "/app/src/layouts/parts/Header.tsx",
      lineNumber: 50,
      columnNumber: 5
    },
    this
  );
}
_s(Header, "GqJ3W7sKvG+ToVgdQcTJHu6hHeg=");
_c = Header;
var _c;
$RefreshReg$(_c, "Header");
if (import.meta.hot && !inWebWorker) {
  window.$RefreshReg$ = prevRefreshReg;
  window.$RefreshSig$ = prevRefreshSig;
}
if (import.meta.hot && !inWebWorker) {
  RefreshRuntime.__hmr_import(import.meta.url).then((currentExports) => {
    RefreshRuntime.registerExportsForReactRefresh("/app/src/layouts/parts/Header.tsx", currentExports);
    import.meta.hot.accept((nextExports) => {
      if (!nextExports) return;
      const invalidateMessage = RefreshRuntime.validateRefreshBoundaryAndEnqueueUpdate("/app/src/layouts/parts/Header.tsx", currentExports, nextExports);
      if (invalidateMessage) import.meta.hot.invalidate(invalidateMessage);
    });
  });
}

//# sourceMappingURL=data:application/json;base64,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RWZmZWN0IiwiSGVhZGVyIiwiX3MiLCJpc01vYmlsZU1lbnVPcGVuIiwic2V0SXNNb2JpbGVNZW51T3BlbiIsInNjcm9sbGVkIiwic2V0U2Nyb2xsZWQiLCJoYW5kbGVTY3JvbGwiLCJ3aW5kb3ciLCJzY3JvbGxZIiwiYWRkRXZlbnRMaXN0ZW5lciIsInBhc3NpdmUiLCJyZW1vdmVFdmVudExpc3RlbmVyIiwibmF2SXRlbXMiLCJocmVmIiwibGFiZWwiLCJpc1JvdXRlIiwiaGFuZGxlTmF2Q2xpY2siLCJzdGFydHNXaXRoIiwiZWwiLCJkb2N1bWVudCIsInF1ZXJ5U2VsZWN0b3IiLCJzY3JvbGxJbnRvVmlldyIsImJlaGF2aW9yIiwiYmFja2dyb3VuZCIsImJhY2tkcm9wRmlsdGVyIiwiYm9yZGVyQm90dG9tIiwibWFwIiwiaXRlbSIsImNvbG9yIiwiZm9udEZhbWlseSIsImxldHRlclNwYWNpbmciLCJlIiwiY3VycmVudFRhcmdldCIsInN0eWxlIiwiYm9yZGVyUmFkaXVzIiwiYm94U2hhZG93IiwiZmlsZSIsInRhZ05hbWUiLCJzb3VyY2VLaW5kIiwiY29udGVudEtleSIsImNvbnRlbnRLZXlUZW1wbGF0ZSIsImV4cHJlc3Npb25IYXNoIiwiYm9yZGVyQ29sb3IiLCJfYyJdLCJpZ25vcmVMaXN0IjpbXSwic291cmNlcyI6WyJIZWFkZXIudHN4Il0sInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IExpbmsgfSBmcm9tICdyZWFjdC1yb3V0ZXItZG9tJztcbmltcG9ydCB7IE1lbnUsIFggfSBmcm9tICdsdWNpZGUtcmVhY3QnO1xuaW1wb3J0IHsgdXNlU3RhdGUsIHVzZUVmZmVjdCB9IGZyb20gJ3JlYWN0JztcblxuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gSGVhZGVyKCkge1xuICBjb25zdCBbaXNNb2JpbGVNZW51T3Blbiwgc2V0SXNNb2JpbGVNZW51T3Blbl0gPSB1c2VTdGF0ZShmYWxzZSk7XG4gIGNvbnN0IFtzY3JvbGxlZCwgc2V0U2Nyb2xsZWRdID0gdXNlU3RhdGUoZmFsc2UpO1xuXG4gIHVzZUVmZmVjdCgoKSA9PiB7XG4gICAgY29uc3QgaGFuZGxlU2Nyb2xsID0gKCkgPT4gc2V0U2Nyb2xsZWQod2luZG93LnNjcm9sbFkgPiAyMCk7XG4gICAgd2luZG93LmFkZEV2ZW50TGlzdGVuZXIoJ3Njcm9sbCcsIGhhbmRsZVNjcm9sbCwgeyBwYXNzaXZlOiB0cnVlIH0pO1xuICAgIHJldHVybiAoKSA9PiB3aW5kb3cucmVtb3ZlRXZlbnRMaXN0ZW5lcignc2Nyb2xsJywgaGFuZGxlU2Nyb2xsKTtcbiAgfSwgW10pO1xuXG4gIGNvbnN0IG5hdkl0ZW1zID0gW1xuICAgIHsgaHJlZjogJy9wcm9kdWN0cycsIGxhYmVsOiAnUHJvZHVjdHMnLCBpc1JvdXRlOiB0cnVlIH0sXG4gICAgeyBocmVmOiAnL3N0dWRpbycsIGxhYmVsOiAnU3R1ZGlvJywgaXNSb3V0ZTogdHJ1ZSB9LFxuICAgIHsgaHJlZjogJy9hYm91dCcsIGxhYmVsOiAnQWJvdXQnLCBpc1JvdXRlOiB0cnVlIH0sXG4gICAgeyBocmVmOiAnL2NvbnRhY3QnLCBsYWJlbDogJ0NvbnRhY3QnLCBpc1JvdXRlOiB0cnVlIH0sXG4gIF07XG5cbiAgY29uc3QgaGFuZGxlTmF2Q2xpY2sgPSAoaHJlZjogc3RyaW5nKSA9PiB7XG4gICAgc2V0SXNNb2JpbGVNZW51T3BlbihmYWxzZSk7XG4gICAgaWYgKGhyZWYuc3RhcnRzV2l0aCgnIycpKSB7XG4gICAgICBjb25zdCBlbCA9IGRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoaHJlZik7XG4gICAgICBpZiAoZWwpIGVsLnNjcm9sbEludG9WaWV3KHsgYmVoYXZpb3I6ICdzbW9vdGgnIH0pO1xuICAgIH1cbiAgfTtcblxuICByZXR1cm4gKFxuICAgIDxoZWFkZXJcbiAgICAgIGNsYXNzTmFtZT1cInN0aWNreSB0b3AtMCB6LTUwIHRyYW5zaXRpb24tYWxsIGR1cmF0aW9uLTMwMFwiXG4gICAgICBzdHlsZT17e1xuICAgICAgICBiYWNrZ3JvdW5kOiBzY3JvbGxlZFxuICAgICAgICAgID8gJ3JnYmEoMTAsIDcsIDYsIDAuOTcpJ1xuICAgICAgICAgIDogJ3JnYmEoMTAsIDcsIDYsIDAuODUpJyxcbiAgICAgICAgYmFja2Ryb3BGaWx0ZXI6ICdibHVyKDEycHgpJyxcbiAgICAgICAgYm9yZGVyQm90dG9tOiBzY3JvbGxlZCA/ICcxcHggc29saWQgcmdiYSgyNTUsIDEyMiwgMzgsIDAuMTUpJyA6ICcxcHggc29saWQgdHJhbnNwYXJlbnQnLFxuICAgICAgfX1cbiAgICA+XG4gICAgICA8ZGl2IGNsYXNzTmFtZT1cImNvbnRhaW5lciBteC1hdXRvIHB4LTZcIj5cbiAgICAgICAgPGRpdiBjbGFzc05hbWU9XCJmbGV4IGgtMjAgaXRlbXMtY2VudGVyIGp1c3RpZnktYmV0d2VlblwiPlxuICAgICAgICAgIHsvKiBMb2dvICovfVxuICAgICAgICAgIDxMaW5rIHRvPVwiL1wiIGNsYXNzTmFtZT1cImZsZXggaXRlbXMtY2VudGVyIHNocmluay0wXCI+XG4gICAgICAgICAgICA8aW1nXG4gICAgICAgICAgICAgIHNyYz1cIi9haXJvLWFzc2V0cy9pbWFnZXMvbG9nby9ob3Jpem9udGFsXCJcbiAgICAgICAgICAgICAgYWx0PVwiV2l6YXJkIFByb2R1Y3Rpb25zIEFJIFN0dWRpb1wiXG4gICAgICAgICAgICAgIGNsYXNzTmFtZT1cImgtMTAgdy1hdXRvIG9iamVjdC1jb250YWluIHNocmluay0wXCJcbiAgICAgICAgICAgIC8+XG4gICAgICAgICAgPC9MaW5rPlxuXG4gICAgICAgICAgey8qIERlc2t0b3AgTmF2ICovfVxuICAgICAgICAgIDxuYXYgY2xhc3NOYW1lPVwiaGlkZGVuIG1kOmZsZXggaXRlbXMtY2VudGVyIGdhcC04XCIgYXJpYS1sYWJlbD1cIk1haW4gbmF2aWdhdGlvblwiPlxuICAgICAgICAgICAge25hdkl0ZW1zLm1hcCgoaXRlbSkgPT5cbiAgICAgICAgICAgICAgaXRlbS5pc1JvdXRlID8gKFxuICAgICAgICAgICAgICAgIDxMaW5rXG4gICAgICAgICAgICAgICAgICBrZXk9e2l0ZW0uaHJlZn1cbiAgICAgICAgICAgICAgICAgIHRvPXtpdGVtLmhyZWZ9XG4gICAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJ0ZXh0LXNtIGZvbnQtbWVkaXVtIHRyYWNraW5nLXdpZGUgdHJhbnNpdGlvbi1jb2xvcnMgZHVyYXRpb24tMjAwXCJcbiAgICAgICAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgICAgICAgIGNvbG9yOiAncmdiYSgyNDUsIDIzNywgMjI4LCAwLjcpJyxcbiAgICAgICAgICAgICAgICAgICAgZm9udEZhbWlseTogJ3ZhcigtLWZvbnQtc2FucyknLFxuICAgICAgICAgICAgICAgICAgICBsZXR0ZXJTcGFjaW5nOiAnMC4wNWVtJyxcbiAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgICBvbk1vdXNlRW50ZXI9eyhlKSA9PiAoKGUuY3VycmVudFRhcmdldCBhcyBIVE1MRWxlbWVudCkuc3R5bGUuY29sb3IgPSAnI2ZmN2EyNicpfVxuICAgICAgICAgICAgICAgICAgb25Nb3VzZUxlYXZlPXsoZSkgPT4gKChlLmN1cnJlbnRUYXJnZXQgYXMgSFRNTEVsZW1lbnQpLnN0eWxlLmNvbG9yID0gJ3JnYmEoMjQ1LCAyMzcsIDIyOCwgMC43KScpfVxuICAgICAgICAgICAgICAgID5cbiAgICAgICAgICAgICAgICAgIHtpdGVtLmxhYmVsfVxuICAgICAgICAgICAgICAgIDwvTGluaz5cbiAgICAgICAgICAgICAgKSA6IChcbiAgICAgICAgICAgICAgICA8YnV0dG9uXG4gICAgICAgICAgICAgICAgICBrZXk9e2l0ZW0uaHJlZn1cbiAgICAgICAgICAgICAgICAgIG9uQ2xpY2s9eygpID0+IGhhbmRsZU5hdkNsaWNrKGl0ZW0uaHJlZil9XG4gICAgICAgICAgICAgICAgICBjbGFzc05hbWU9XCJ0ZXh0LXNtIGZvbnQtbWVkaXVtIHRyYWNraW5nLXdpZGUgdHJhbnNpdGlvbi1jb2xvcnMgZHVyYXRpb24tMjAwIGN1cnNvci1wb2ludGVyXCJcbiAgICAgICAgICAgICAgICAgIHN0eWxlPXt7XG4gICAgICAgICAgICAgICAgICAgIGNvbG9yOiAncmdiYSgyNDUsIDIzNywgMjI4LCAwLjcpJyxcbiAgICAgICAgICAgICAgICAgICAgZm9udEZhbWlseTogJ3ZhcigtLWZvbnQtc2FucyknLFxuICAgICAgICAgICAgICAgICAgICBsZXR0ZXJTcGFjaW5nOiAnMC4wNWVtJyxcbiAgICAgICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgICAgICBvbk1vdXNlRW50ZXI9eyhlKSA9PiAoZS5jdXJyZW50VGFyZ2V0LnN0eWxlLmNvbG9yID0gJyNmZjdhMjYnKX1cbiAgICAgICAgICAgICAgICAgIG9uTW91c2VMZWF2ZT17KGUpID0+IChlLmN1cnJlbnRUYXJnZXQuc3R5bGUuY29sb3IgPSAncmdiYSgyNDUsIDIzNywgMjI4LCAwLjcpJyl9XG4gICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAge2l0ZW0ubGFiZWx9XG4gICAgICAgICAgICAgICAgPC9idXR0b24+XG4gICAgICAgICAgICAgIClcbiAgICAgICAgICAgICl9XG4gICAgICAgICAgICA8YVxuICAgICAgICAgICAgICBocmVmPVwiaHR0cHM6Ly93cGFpc3R1ZGlvLmd1bXJvYWQuY29tXCJcbiAgICAgICAgICAgICAgdGFyZ2V0PVwiX2JsYW5rXCJcbiAgICAgICAgICAgICAgcmVsPVwibm9vcGVuZXIgbm9yZWZlcnJlclwiXG4gICAgICAgICAgICAgIGNsYXNzTmFtZT1cInRleHQtc20gZm9udC1zZW1pYm9sZCBweC01IHB5LTIgdHJhbnNpdGlvbi1hbGwgZHVyYXRpb24tMjAwXCJcbiAgICAgICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgICAgICBiYWNrZ3JvdW5kOiAnbGluZWFyLWdyYWRpZW50KDEzNWRlZywgI2ZmN2EyNiwgI2U4NDUxYyknLFxuICAgICAgICAgICAgICAgIGNvbG9yOiAnI2ZmZicsXG4gICAgICAgICAgICAgICAgYm9yZGVyUmFkaXVzOiAnMnB4JyxcbiAgICAgICAgICAgICAgICBsZXR0ZXJTcGFjaW5nOiAnMC4wNmVtJyxcbiAgICAgICAgICAgICAgICBmb250RmFtaWx5OiAndmFyKC0tZm9udC1zYW5zKScsXG4gICAgICAgICAgICAgICAgYm94U2hhZG93OiAnMCAwIDE2cHggcmdiYSgyNTUsIDEyMiwgMzgsIDAuMyknLFxuICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICBvbk1vdXNlRW50ZXI9eyhlKSA9PiB7XG4gICAgICAgICAgICAgICAgKGUuY3VycmVudFRhcmdldCBhcyBIVE1MRWxlbWVudCkuc3R5bGUuYm94U2hhZG93ID0gJzAgMCAyOHB4IHJnYmEoMjU1LCAxMjIsIDM4LCAwLjU1KSc7XG4gICAgICAgICAgICAgIH19XG4gICAgICAgICAgICAgIG9uTW91c2VMZWF2ZT17KGUpID0+IHtcbiAgICAgICAgICAgICAgICAoZS5jdXJyZW50VGFyZ2V0IGFzIEhUTUxFbGVtZW50KS5zdHlsZS5ib3hTaGFkb3cgPSAnMCAwIDE2cHggcmdiYSgyNTUsIDEyMiwgMzgsIDAuMyknO1xuICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgPlxuICAgICAgICAgICAgICBTdG9yZWZyb250XG4gICAgICAgICAgICA8L2E+XG4gICAgICAgICAgPC9uYXY+XG5cbiAgICAgICAgICB7LyogTW9iaWxlIHRvZ2dsZSAqL31cbiAgICAgICAgICA8YnV0dG9uXG4gICAgICAgICAgICBvbkNsaWNrPXsoKSA9PiBzZXRJc01vYmlsZU1lbnVPcGVuKCFpc01vYmlsZU1lbnVPcGVuKX1cbiAgICAgICAgICAgIGNsYXNzTmFtZT1cIm1kOmhpZGRlbiBwLTIgcm91bmRlZCB0cmFuc2l0aW9uLWNvbG9yc1wiXG4gICAgICAgICAgICBzdHlsZT17eyBjb2xvcjogJyNmZjdhMjYnIH19XG4gICAgICAgICAgICBhcmlhLWxhYmVsPVwiVG9nZ2xlIG1lbnVcIlxuICAgICAgICAgID5cbiAgICAgICAgICAgIHtpc01vYmlsZU1lbnVPcGVuID8gPFggc2l6ZT17MjJ9IC8+IDogPE1lbnUgc2l6ZT17MjJ9IC8+fVxuICAgICAgICAgIDwvYnV0dG9uPlxuICAgICAgICA8L2Rpdj5cblxuICAgICAgICB7LyogTW9iaWxlIG1lbnUgKi99XG4gICAgICAgIHtpc01vYmlsZU1lbnVPcGVuICYmIChcbiAgICAgICAgICA8ZGl2XG4gICAgICAgICAgICBjbGFzc05hbWU9XCJtZDpoaWRkZW4gcHktNCBib3JkZXItdFwiXG4gICAgICAgICAgICBzdHlsZT17eyBib3JkZXJDb2xvcjogJ3JnYmEoMjU1LCAxMjIsIDM4LCAwLjE1KScgfX1cbiAgICAgICAgICA+XG4gICAgICAgICAgICA8bmF2IGNsYXNzTmFtZT1cImZsZXggZmxleC1jb2wgZ2FwLTFcIiBhcmlhLWxhYmVsPVwiTW9iaWxlIG5hdmlnYXRpb25cIj5cbiAgICAgICAgICAgICAge25hdkl0ZW1zLm1hcCgoaXRlbSkgPT5cbiAgICAgICAgICAgICAgICBpdGVtLmlzUm91dGUgPyAoXG4gICAgICAgICAgICAgICAgICA8TGlua1xuICAgICAgICAgICAgICAgICAgICBrZXk9e2l0ZW0uaHJlZn1cbiAgICAgICAgICAgICAgICAgICAgdG89e2l0ZW0uaHJlZn1cbiAgICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwidGV4dC1zbSBmb250LW1lZGl1bSBweS0zIHB4LTIgdHJhbnNpdGlvbi1jb2xvcnMgZHVyYXRpb24tMjAwXCJcbiAgICAgICAgICAgICAgICAgICAgc3R5bGU9e3sgY29sb3I6ICdyZ2JhKDI0NSwgMjM3LCAyMjgsIDAuNzUpJywgZm9udEZhbWlseTogJ3ZhcigtLWZvbnQtc2FucyknIH19XG4gICAgICAgICAgICAgICAgICAgIG9uQ2xpY2s9eygpID0+IHNldElzTW9iaWxlTWVudU9wZW4oZmFsc2UpfVxuICAgICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAgICB7aXRlbS5sYWJlbH1cbiAgICAgICAgICAgICAgICAgIDwvTGluaz5cbiAgICAgICAgICAgICAgICApIDogKFxuICAgICAgICAgICAgICAgICAgPGJ1dHRvblxuICAgICAgICAgICAgICAgICAgICBrZXk9e2l0ZW0uaHJlZn1cbiAgICAgICAgICAgICAgICAgICAgb25DbGljaz17KCkgPT4gaGFuZGxlTmF2Q2xpY2soaXRlbS5ocmVmKX1cbiAgICAgICAgICAgICAgICAgICAgY2xhc3NOYW1lPVwidGV4dC1zbSBmb250LW1lZGl1bSBweS0zIHB4LTIgdGV4dC1sZWZ0IHRyYW5zaXRpb24tY29sb3JzIGR1cmF0aW9uLTIwMCBjdXJzb3ItcG9pbnRlclwiXG4gICAgICAgICAgICAgICAgICAgIHN0eWxlPXt7IGNvbG9yOiAncmdiYSgyNDUsIDIzNywgMjI4LCAwLjc1KScsIGZvbnRGYW1pbHk6ICd2YXIoLS1mb250LXNhbnMpJyB9fVxuICAgICAgICAgICAgICAgICAgPlxuICAgICAgICAgICAgICAgICAgICB7aXRlbS5sYWJlbH1cbiAgICAgICAgICAgICAgICAgIDwvYnV0dG9uPlxuICAgICAgICAgICAgICAgIClcbiAgICAgICAgICAgICAgKX1cbiAgICAgICAgICAgICAgPGFcbiAgICAgICAgICAgICAgICBocmVmPVwiaHR0cHM6Ly93cGFpc3R1ZGlvLmd1bXJvYWQuY29tXCJcbiAgICAgICAgICAgICAgICB0YXJnZXQ9XCJfYmxhbmtcIlxuICAgICAgICAgICAgICAgIHJlbD1cIm5vb3BlbmVyIG5vcmVmZXJyZXJcIlxuICAgICAgICAgICAgICAgIGNsYXNzTmFtZT1cIm10LTMgdGV4dC1zbSBmb250LXNlbWlib2xkIHB4LTQgcHktMyB0ZXh0LWNlbnRlclwiXG4gICAgICAgICAgICAgICAgc3R5bGU9e3tcbiAgICAgICAgICAgICAgICAgIGJhY2tncm91bmQ6ICdsaW5lYXItZ3JhZGllbnQoMTM1ZGVnLCAjZmY3YTI2LCAjZTg0NTFjKScsXG4gICAgICAgICAgICAgICAgICBjb2xvcjogJyNmZmYnLFxuICAgICAgICAgICAgICAgICAgYm9yZGVyUmFkaXVzOiAnMnB4JyxcbiAgICAgICAgICAgICAgICB9fVxuICAgICAgICAgICAgICA+XG4gICAgICAgICAgICAgICAgU3RvcmVmcm9udFxuICAgICAgICAgICAgICA8L2E+XG4gICAgICAgICAgICA8L25hdj5cbiAgICAgICAgICA8L2Rpdj5cbiAgICAgICAgKX1cbiAgICAgIDwvZGl2PlxuICAgIDwvaGVhZGVyPlxuICApO1xufVxuIl0sImZpbGUiOiIvYXBwL3NyYy9sYXlvdXRzL3BhcnRzL0hlYWRlci50c3gifQ==