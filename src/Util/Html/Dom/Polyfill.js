if (typeof global !== "undefined" && !global.DOMParser) {
  const { JSDOM } = await import(/* @vite-ignore */ "jsdom");
  global.DOMParser = new JSDOM().window.DOMParser;
}

// This function is a no-op because the polyfill is executed at module load time (Top-Level Await).
// However, we must keep this export to satisfy the PureScript FFI (`foreign import polyfillDOMParser`), 
// and calling it ensures that this JS module is included in the dependency tree and evaluated by Node.js.
export const polyfillDOMParser = () => {};
