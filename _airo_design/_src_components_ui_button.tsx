import { createHotContext as __vite__createHotContext } from "/@vite/client";import.meta.hot = __vite__createHotContext("/src/components/ui/button.tsx");import __vite__cjsImport0_react_jsxDevRuntime from "/node_modules/.vite/deps/react_jsx-dev-runtime.js?v=38c95354"; const jsxDEV = __vite__cjsImport0_react_jsxDevRuntime["jsxDEV"];
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
  window.$RefreshReg$ = RefreshRuntime.getRefreshReg("/app/src/components/ui/button.tsx");
  window.$RefreshSig$ = RefreshRuntime.createSignatureFunctionForTransform;
}
import __vite__cjsImport3_react from "/node_modules/.vite/deps/react.js?v=38c95354"; const React = ((m) => m?.__esModule ? m : { ...typeof m === "object" && !Array.isArray(m) || typeof m === "function" ? m : {}, default: m })(__vite__cjsImport3_react);
import { Slot } from "/node_modules/.vite/deps/@radix-ui_react-slot.js?v=38c95354";
import { cva } from "/node_modules/.vite/deps/class-variance-authority.js?v=38c95354";
import { cn } from "/src/lib/utils.ts";
const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-[var(--radius-button)] text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-transparent text-foreground hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline"
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-[var(--radius-button)] px-3",
        lg: "h-11 rounded-[var(--radius-button)] px-8",
        icon: "h-10 w-10"
      }
    },
    defaultVariants: {
      variant: "default",
      size: "default"
    }
  }
);
const Button = React.forwardRef(
  _c = ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return /* @__PURE__ */ jsxDEV(
      Comp,
      {
        className: cn(buttonVariants({ variant, size, className })),
        ref,
        ...props
      },
      void 0,
      false,
      {
        fileName: "/app/src/components/ui/button.tsx",
        lineNumber: 65,
        columnNumber: 5
      },
      this
    );
  }
);
_c2 = Button;
Button.displayName = "Button";
export { Button, buttonVariants };
var _c, _c2;
$RefreshReg$(_c, "Button$React.forwardRef");
$RefreshReg$(_c2, "Button");
if (import.meta.hot && !inWebWorker) {
  window.$RefreshReg$ = prevRefreshReg;
  window.$RefreshSig$ = prevRefreshSig;
}
if (import.meta.hot && !inWebWorker) {
  RefreshRuntime.__hmr_import(import.meta.url).then((currentExports) => {
    RefreshRuntime.registerExportsForReactRefresh("/app/src/components/ui/button.tsx", currentExports);
    import.meta.hot.accept((nextExports) => {
      if (!nextExports) return;
      const invalidateMessage = RefreshRuntime.validateRefreshBoundaryAndEnqueueUpdate("/app/src/components/ui/button.tsx", currentExports, nextExports);
      if (invalidateMessage) import.meta.hot.invalidate(invalidateMessage);
    });
  });
}

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJtYXBwaW5ncyI6IkFBNkNHOzs7Ozs7Ozs7Ozs7Ozs7O0FBN0NILFlBQVlBLFdBQVc7QUFDdkIsU0FBU0MsWUFBWTtBQUNyQixTQUFTQyxXQUE4QjtBQUV2QyxTQUFTQyxVQUFVO0FBRW5CLE1BQU1DLGlCQUFpQkY7QUFBQUEsRUFDdEI7QUFBQSxFQUNBO0FBQUEsSUFDQ0csVUFBVTtBQUFBLE1BQ1RDLFNBQVM7QUFBQSxRQUNSQyxTQUFTO0FBQUEsUUFDVEMsYUFDQztBQUFBLFFBQ0RDLFNBQ0M7QUFBQSxRQUNEQyxXQUNDO0FBQUEsUUFDREMsT0FBTztBQUFBLFFBQ1BDLE1BQU07QUFBQSxNQUNQO0FBQUEsTUFDQUMsTUFBTTtBQUFBLFFBQ0xOLFNBQVM7QUFBQSxRQUNUTyxJQUFJO0FBQUEsUUFDSkMsSUFBSTtBQUFBLFFBQ0pDLE1BQU07QUFBQSxNQUNQO0FBQUEsSUFDRDtBQUFBLElBQ0FDLGlCQUFpQjtBQUFBLE1BQ2hCWCxTQUFTO0FBQUEsTUFDVE8sTUFBTTtBQUFBLElBQ1A7QUFBQSxFQUNEO0FBQ0Q7QUFRQSxNQUFNSyxTQUFTbEIsTUFBTW1CO0FBQUFBLEVBQTBDQyxLQUM5REEsQ0FBQyxFQUFFQyxXQUFXZixTQUFTTyxNQUFNUyxVQUFVLE9BQU8sR0FBR0MsTUFBTSxHQUFHQyxRQUFRO0FBQ2pFLFVBQU1DLE9BQU9ILFVBQVVyQixPQUFPO0FBQzlCLFdBQ0M7QUFBQSxNQUFDO0FBQUE7QUFBQSxRQUNBLFdBQVdFLEdBQUdDLGVBQWUsRUFBRUUsU0FBU08sTUFBTVEsVUFBVSxDQUFDLENBQUM7QUFBQSxRQUMxRDtBQUFBLFFBQ0EsR0FBSUU7QUFBQUE7QUFBQUEsTUFITDtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUE7QUFBQTtBQUFBO0FBQUEsSUFHVztBQUFBLEVBR2I7QUFDRDtBQUFFRyxNQVhJUjtBQVlOQSxPQUFPUyxjQUFjO0FBRXJCLFNBQVNULFFBQVFkO0FBQWlCLElBQUFnQixJQUFBTTtBQUFBLGFBQUFOLElBQUE7QUFBQSxhQUFBTSxLQUFBIiwibmFtZXMiOlsiUmVhY3QiLCJTbG90IiwiY3ZhIiwiY24iLCJidXR0b25WYXJpYW50cyIsInZhcmlhbnRzIiwidmFyaWFudCIsImRlZmF1bHQiLCJkZXN0cnVjdGl2ZSIsIm91dGxpbmUiLCJzZWNvbmRhcnkiLCJnaG9zdCIsImxpbmsiLCJzaXplIiwic20iLCJsZyIsImljb24iLCJkZWZhdWx0VmFyaWFudHMiLCJCdXR0b24iLCJmb3J3YXJkUmVmIiwiX2MiLCJjbGFzc05hbWUiLCJhc0NoaWxkIiwicHJvcHMiLCJyZWYiLCJDb21wIiwiX2MyIiwiZGlzcGxheU5hbWUiXSwiaWdub3JlTGlzdCI6W10sInNvdXJjZXMiOlsiYnV0dG9uLnRzeCJdLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgKiBhcyBSZWFjdCBmcm9tIFwicmVhY3RcIjtcbmltcG9ydCB7IFNsb3QgfSBmcm9tIFwiQHJhZGl4LXVpL3JlYWN0LXNsb3RcIjtcbmltcG9ydCB7IGN2YSwgdHlwZSBWYXJpYW50UHJvcHMgfSBmcm9tIFwiY2xhc3MtdmFyaWFuY2UtYXV0aG9yaXR5XCI7XG5cbmltcG9ydCB7IGNuIH0gZnJvbSBcIkAvbGliL3V0aWxzXCI7XG5cbmNvbnN0IGJ1dHRvblZhcmlhbnRzID0gY3ZhKFxuXHRcImlubGluZS1mbGV4IGl0ZW1zLWNlbnRlciBqdXN0aWZ5LWNlbnRlciBnYXAtMiB3aGl0ZXNwYWNlLW5vd3JhcCByb3VuZGVkLVt2YXIoLS1yYWRpdXMtYnV0dG9uKV0gdGV4dC1zbSBmb250LW1lZGl1bSByaW5nLW9mZnNldC1iYWNrZ3JvdW5kIHRyYW5zaXRpb24tY29sb3JzIGZvY3VzLXZpc2libGU6b3V0bGluZS1ub25lIGZvY3VzLXZpc2libGU6cmluZy0yIGZvY3VzLXZpc2libGU6cmluZy1yaW5nIGZvY3VzLXZpc2libGU6cmluZy1vZmZzZXQtMiBkaXNhYmxlZDpwb2ludGVyLWV2ZW50cy1ub25lIGRpc2FibGVkOm9wYWNpdHktNTAgWyZfc3ZnXTpwb2ludGVyLWV2ZW50cy1ub25lIFsmX3N2Z106c2l6ZS00IFsmX3N2Z106c2hyaW5rLTBcIixcblx0e1xuXHRcdHZhcmlhbnRzOiB7XG5cdFx0XHR2YXJpYW50OiB7XG5cdFx0XHRcdGRlZmF1bHQ6IFwiYmctcHJpbWFyeSB0ZXh0LXByaW1hcnktZm9yZWdyb3VuZCBob3ZlcjpiZy1wcmltYXJ5LzkwXCIsXG5cdFx0XHRcdGRlc3RydWN0aXZlOlxuXHRcdFx0XHRcdFwiYmctZGVzdHJ1Y3RpdmUgdGV4dC1kZXN0cnVjdGl2ZS1mb3JlZ3JvdW5kIGhvdmVyOmJnLWRlc3RydWN0aXZlLzkwXCIsXG5cdFx0XHRcdG91dGxpbmU6XG5cdFx0XHRcdFx0XCJib3JkZXIgYm9yZGVyLWlucHV0IGJnLXRyYW5zcGFyZW50IHRleHQtZm9yZWdyb3VuZCBob3ZlcjpiZy1hY2NlbnQgaG92ZXI6dGV4dC1hY2NlbnQtZm9yZWdyb3VuZFwiLFxuXHRcdFx0XHRzZWNvbmRhcnk6XG5cdFx0XHRcdFx0XCJiZy1zZWNvbmRhcnkgdGV4dC1zZWNvbmRhcnktZm9yZWdyb3VuZCBob3ZlcjpiZy1zZWNvbmRhcnkvODBcIixcblx0XHRcdFx0Z2hvc3Q6IFwiaG92ZXI6YmctYWNjZW50IGhvdmVyOnRleHQtYWNjZW50LWZvcmVncm91bmRcIixcblx0XHRcdFx0bGluazogXCJ0ZXh0LXByaW1hcnkgdW5kZXJsaW5lLW9mZnNldC00IGhvdmVyOnVuZGVybGluZVwiLFxuXHRcdFx0fSxcblx0XHRcdHNpemU6IHtcblx0XHRcdFx0ZGVmYXVsdDogXCJoLTEwIHB4LTQgcHktMlwiLFxuXHRcdFx0XHRzbTogXCJoLTkgcm91bmRlZC1bdmFyKC0tcmFkaXVzLWJ1dHRvbildIHB4LTNcIixcblx0XHRcdFx0bGc6IFwiaC0xMSByb3VuZGVkLVt2YXIoLS1yYWRpdXMtYnV0dG9uKV0gcHgtOFwiLFxuXHRcdFx0XHRpY29uOiBcImgtMTAgdy0xMFwiLFxuXHRcdFx0fSxcblx0XHR9LFxuXHRcdGRlZmF1bHRWYXJpYW50czoge1xuXHRcdFx0dmFyaWFudDogXCJkZWZhdWx0XCIsXG5cdFx0XHRzaXplOiBcImRlZmF1bHRcIixcblx0XHR9LFxuXHR9LFxuKTtcblxuZXhwb3J0IGludGVyZmFjZSBCdXR0b25Qcm9wc1xuXHRleHRlbmRzIFJlYWN0LkJ1dHRvbkhUTUxBdHRyaWJ1dGVzPEhUTUxCdXR0b25FbGVtZW50Pixcblx0XHRWYXJpYW50UHJvcHM8dHlwZW9mIGJ1dHRvblZhcmlhbnRzPiB7XG5cdGFzQ2hpbGQ/OiBib29sZWFuO1xufVxuXG5jb25zdCBCdXR0b24gPSBSZWFjdC5mb3J3YXJkUmVmPEhUTUxCdXR0b25FbGVtZW50LCBCdXR0b25Qcm9wcz4oXG5cdCh7IGNsYXNzTmFtZSwgdmFyaWFudCwgc2l6ZSwgYXNDaGlsZCA9IGZhbHNlLCAuLi5wcm9wcyB9LCByZWYpID0+IHtcblx0XHRjb25zdCBDb21wID0gYXNDaGlsZCA/IFNsb3QgOiBcImJ1dHRvblwiO1xuXHRcdHJldHVybiAoXG5cdFx0XHQ8Q29tcFxuXHRcdFx0XHRjbGFzc05hbWU9e2NuKGJ1dHRvblZhcmlhbnRzKHsgdmFyaWFudCwgc2l6ZSwgY2xhc3NOYW1lIH0pKX1cblx0XHRcdFx0cmVmPXtyZWZ9XG5cdFx0XHRcdHsuLi5wcm9wc31cblx0XHRcdC8+XG5cdFx0KTtcblx0fSxcbik7XG5CdXR0b24uZGlzcGxheU5hbWUgPSBcIkJ1dHRvblwiO1xuXG5leHBvcnQgeyBCdXR0b24sIGJ1dHRvblZhcmlhbnRzIH07XG4iXSwiZmlsZSI6Ii9hcHAvc3JjL2NvbXBvbmVudHMvdWkvYnV0dG9uLnRzeCJ9