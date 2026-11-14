    // Port of Polyfill.js: the jsoup-based FFI does not need a DOMParser
    // global, so the polyfill is inert.
    public static Object polyfillDOMParser = (java.util.function.Supplier<Object>) () -> null;
