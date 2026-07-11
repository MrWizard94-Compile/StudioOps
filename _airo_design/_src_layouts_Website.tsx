import { createHotContext as __vite__createHotContext } from "/@vite/client";import.meta.hot = __vite__createHotContext("/src/layouts/Website.tsx");import __vite__cjsImport0_react_jsxDevRuntime from "/node_modules/.vite/deps/react_jsx-dev-runtime.js?v=38c95354"; const jsxDEV = __vite__cjsImport0_react_jsxDevRuntime["jsxDEV"];
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
  window.$RefreshReg$ = RefreshRuntime.getRefreshReg("/app/src/layouts/Website.tsx");
  window.$RefreshSig$ = RefreshRuntime.createSignatureFunctionForTransform;
}
import { cn } from "/src/lib/utils.ts";
export default function Website({
  children,
  config = {},
  className
}) {
  const {
    layout = {
      maxWidth: "full",
      padding: "md",
      background: "default",
      minHeight: true
    }
  } = config;
  const getBackgroundClass = () => {
    switch (layout.background) {
      case "muted":
        return "bg-muted";
      case "gradient":
        return "bg-gradient-to-b from-background to-muted/20";
      default:
        return "bg-background";
    }
  };
  return /* @__PURE__ */ jsxDEV("div", { className: cn(
    layout.minHeight !== false && "min-h-screen",
    getBackgroundClass(),
    "flex flex-col",
    className
  ), "data-dev-file": "/app/src/layouts/Website.tsx", "data-dev-line": 74, "data-dev-id": "24a66c", children }, void 0, false, {
    fileName: "/app/src/layouts/Website.tsx",
    lineNumber: 93,
    columnNumber: 5
  }, this);
}
_c = Website;
var _c;
$RefreshReg$(_c, "Website");
if (import.meta.hot && !inWebWorker) {
  window.$RefreshReg$ = prevRefreshReg;
  window.$RefreshSig$ = prevRefreshSig;
}
if (import.meta.hot && !inWebWorker) {
  RefreshRuntime.__hmr_import(import.meta.url).then((currentExports) => {
    RefreshRuntime.registerExportsForReactRefresh("/app/src/layouts/Website.tsx", currentExports);
    import.meta.hot.accept((nextExports) => {
      if (!nextExports) return;
      const invalidateMessage = RefreshRuntime.validateRefreshBoundaryAndEnqueueUpdate("/app/src/layouts/Website.tsx", currentExports, nextExports);
      if (invalidateMessage) import.meta.hot.invalidate(invalidateMessage);
    });
  });
}

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJtYXBwaW5ncyI6IkFBeUVJOzs7Ozs7Ozs7Ozs7Ozs7O0FBeEVKLFNBQVNBLFVBQVU7QUFpRG5CLHdCQUF3QkMsUUFBUTtBQUFBLEVBQzlCQztBQUFBQSxFQUNBQyxTQUFTLENBQUM7QUFBQSxFQUNWQztBQUNZLEdBQUc7QUFDZixRQUFNO0FBQUEsSUFDSkMsU0FBUztBQUFBLE1BQ1BDLFVBQVU7QUFBQSxNQUNWQyxTQUFTO0FBQUEsTUFDVEMsWUFBWTtBQUFBLE1BQ1pDLFdBQVc7QUFBQSxJQUNiO0FBQUEsRUFDRixJQUFJTjtBQUVKLFFBQU1PLHFCQUFxQkEsTUFBTTtBQUMvQixZQUFRTCxPQUFPRyxZQUFVO0FBQUEsTUFDdkIsS0FBSztBQUFTLGVBQU87QUFBQSxNQUNyQixLQUFLO0FBQVksZUFBTztBQUFBLE1BQ3hCO0FBQVMsZUFBTztBQUFBLElBQ2xCO0FBQUEsRUFDRjtBQUVBLFNBQ0UsdUJBQUMsU0FBSSxXQUFXUjtBQUFBQSxJQUNkSyxPQUFPSSxjQUFjLFNBQVM7QUFBQSxJQUM5QkMsbUJBQW1CO0FBQUEsSUFDbkI7QUFBQSxJQUNBTjtBQUFBQSxFQUNGLEdBQUUsK0ZBQ0NGLFlBTkg7QUFBQTtBQUFBO0FBQUE7QUFBQSxTQU9BO0FBRUo7QUFBQ1MsS0FoQ3VCVjtBQUFPLElBQUFVO0FBQUEsYUFBQUEsSUFBQSIsIm5hbWVzIjpbImNuIiwiV2Vic2l0ZSIsImNoaWxkcmVuIiwiY29uZmlnIiwiY2xhc3NOYW1lIiwibGF5b3V0IiwibWF4V2lkdGgiLCJwYWRkaW5nIiwiYmFja2dyb3VuZCIsIm1pbkhlaWdodCIsImdldEJhY2tncm91bmRDbGFzcyIsIl9jIl0sImlnbm9yZUxpc3QiOltdLCJzb3VyY2VzIjpbIldlYnNpdGUudHN4Il0sInNvdXJjZXNDb250ZW50IjpbImltcG9ydCBSZWFjdCBmcm9tICdyZWFjdCc7XG5pbXBvcnQgeyBjbiB9IGZyb20gJ0AvbGliL3V0aWxzJztcblxuLyoqXG4gKiBXZWJzaXRlIGxheW91dCBjb25maWd1cmF0aW9uIG9wdGlvbnNcbiAqXG4gKiBEZWZpbmVzIHRoZSBzdHJ1Y3R1cmFsIGxheW91dCBvcHRpb25zIGZvciB0aGUgV2Vic2l0ZSBjb21wb25lbnQuXG4gKiBOb3RlOiBIZWFkZXIgYW5kIEZvb3RlciBhcmUgbm93IHR5cGljYWxseSBtYW5hZ2VkIGJ5IFJvb3RMYXlvdXQgaW4gQXBwLnRzeC5cbiAqL1xuZXhwb3J0IGludGVyZmFjZSBXZWJzaXRlQ29uZmlnIHtcbiAgbGF5b3V0Pzoge1xuICAgIG1heFdpZHRoPzogJ3NtJyB8ICdtZCcgfCAnbGcnIHwgJ3hsJyB8ICcyeGwnIHwgJ2Z1bGwnO1xuICAgIHBhZGRpbmc/OiAnbm9uZScgfCAnc20nIHwgJ21kJyB8ICdsZyc7XG4gICAgYmFja2dyb3VuZD86ICdkZWZhdWx0JyB8ICdtdXRlZCcgfCAnZ3JhZGllbnQnO1xuICAgIG1pbkhlaWdodD86IGJvb2xlYW47XG4gIH07XG59XG5cbmludGVyZmFjZSBXZWJzaXRlUHJvcHMge1xuICBjaGlsZHJlbjogUmVhY3QuUmVhY3ROb2RlO1xuICBjb25maWc/OiBXZWJzaXRlQ29uZmlnO1xuICBjbGFzc05hbWU/OiBzdHJpbmc7XG59XG5cbi8qKlxuICogV2Vic2l0ZSBsYXlvdXQgY29tcG9uZW50XG4gKlxuICogUHJvdmlkZXMgdGhlIHN0cnVjdHVyYWwgY29udGFpbmVyIGZvciB3ZWJzaXRlIHBhZ2VzIHdpdGggY29uZmlndXJhYmxlIGxheW91dCBvcHRpb25zLlxuICogVGhpcyBpcyBhIGxvd2VyLWxldmVsIGNvbXBvbmVudCAtIGZvciBtb3N0IGFwcGxpY2F0aW9ucywgdXNlIFJvb3RMYXlvdXQgaW5zdGVhZCxcbiAqIHdoaWNoIHdyYXBzIHRoaXMgY29tcG9uZW50IGFuZCBwcm92aWRlcyBjZW50cmFsaXplZCBoZWFkZXIvZm9vdGVyIG1hbmFnZW1lbnQuXG4gKlxuICogQHBhcmFtIGNoaWxkcmVuIC0gUGFnZSBjb250ZW50IHRvIHJlbmRlciAoY2FuIGluY2x1ZGUgSGVhZGVyLCBGb290ZXIsIGFuZCBtYWluIGNvbnRlbnQpXG4gKiBAcGFyYW0gY29uZmlnIC0gTGF5b3V0IGNvbmZpZ3VyYXRpb24gb3B0aW9uc1xuICogQHBhcmFtIGNsYXNzTmFtZSAtIEFkZGl0aW9uYWwgQ1NTIGNsYXNzZXNcbiAqXG4gKiBAZXhhbXBsZVxuICogYGBgdHN4XG4gKiAvLyBUeXBpY2FsIHVzYWdlIHdpdGggUm9vdExheW91dCAocmVjb21tZW5kZWQpIOKAlCBjaGlsZHJlbiBvbmx5OyBlZGl0IEhlYWRlci50c3gvRm9vdGVyLnRzeCB0byBjdXN0b21pemVcbiAqIDxSb290TGF5b3V0PlxuICogICA8WW91clBhZ2UgLz5cbiAqIDwvUm9vdExheW91dD5cbiAqXG4gKiAvLyBEaXJlY3QgdXNhZ2UgKGFkdmFuY2VkKSDigJQgV2Vic2l0ZSB0YWtlcyBjb25maWcubGF5b3V0OyBIZWFkZXIvRm9vdGVyIHRha2Ugbm8gcHJvcHNcbiAqIDxXZWJzaXRlIGNvbmZpZz17eyBsYXlvdXQ6IHsgYmFja2dyb3VuZDogJ2dyYWRpZW50JyB9IH19PlxuICogICA8SGVhZGVyIC8+XG4gKiAgIDxtYWluPllvdXIgY29udGVudDwvbWFpbj5cbiAqICAgPEZvb3RlciAvPlxuICogPC9XZWJzaXRlPlxuICogYGBgXG4gKi9cbmV4cG9ydCBkZWZhdWx0IGZ1bmN0aW9uIFdlYnNpdGUoe1xuICBjaGlsZHJlbixcbiAgY29uZmlnID0ge30sXG4gIGNsYXNzTmFtZVxufTogV2Vic2l0ZVByb3BzKSB7XG4gIGNvbnN0IHtcbiAgICBsYXlvdXQgPSB7XG4gICAgICBtYXhXaWR0aDogJ2Z1bGwnLFxuICAgICAgcGFkZGluZzogJ21kJyxcbiAgICAgIGJhY2tncm91bmQ6ICdkZWZhdWx0JyxcbiAgICAgIG1pbkhlaWdodDogdHJ1ZVxuICAgIH1cbiAgfSA9IGNvbmZpZztcblxuICBjb25zdCBnZXRCYWNrZ3JvdW5kQ2xhc3MgPSAoKSA9PiB7XG4gICAgc3dpdGNoIChsYXlvdXQuYmFja2dyb3VuZCkge1xuICAgICAgY2FzZSAnbXV0ZWQnOiByZXR1cm4gJ2JnLW11dGVkJztcbiAgICAgIGNhc2UgJ2dyYWRpZW50JzogcmV0dXJuICdiZy1ncmFkaWVudC10by1iIGZyb20tYmFja2dyb3VuZCB0by1tdXRlZC8yMCc7XG4gICAgICBkZWZhdWx0OiByZXR1cm4gJ2JnLWJhY2tncm91bmQnO1xuICAgIH1cbiAgfTtcblxuICByZXR1cm4gKFxuICAgIDxkaXYgY2xhc3NOYW1lPXtjbihcbiAgICAgIGxheW91dC5taW5IZWlnaHQgIT09IGZhbHNlICYmIFwibWluLWgtc2NyZWVuXCIsXG4gICAgICBnZXRCYWNrZ3JvdW5kQ2xhc3MoKSxcbiAgICAgIFwiZmxleCBmbGV4LWNvbFwiLFxuICAgICAgY2xhc3NOYW1lXG4gICAgKX0+XG4gICAgICB7Y2hpbGRyZW59XG4gICAgPC9kaXY+XG4gICk7XG59XG4iXSwiZmlsZSI6Ii9hcHAvc3JjL2xheW91dHMvV2Vic2l0ZS50c3gifQ==