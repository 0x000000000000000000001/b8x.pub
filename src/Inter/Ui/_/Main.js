export const _isBlacklistedError = (url) => (msg) => () => {
  if (typeof window !== 'undefined' && window.location) {
    const checkUrl = url || window.location.pathname;
    if (checkUrl.includes('/wp-json')
      || checkUrl.includes('/wp-content')
      || checkUrl.includes('/feed')
    ) {
      return true;
    }
  }

  if (msg.includes('ResizeObserver loop limit exceeded') 
    || msg.includes('ResizeObserver loop completed with undelivered notifications')
    || msg.includes('wp-json')
    || msg.includes('Failed to fetch dynamically imported module') && msg.includes('xxhash-wasm')
    || msg === 'Script error.'
    || msg.includes('The I/O read operation failed')
    || msg.includes('SecurityError: The operation is insecure')
    || msg.includes("Can't find variable: WebAssembly")
    || msg.includes('Expected "404"')
    || msg.includes('chrome-extension://')
    || msg.includes('webkit-masked-url')
    // AdScore injects elements with inline handlers that expect the AdMaster
    // SDK global `admasterImgReadyChange`; when that SDK is absent (blocked or
    // not loaded for the ad slot), the inline handler throws for every visitor.
    || msg.includes('admasterImgReadyChange')
    || msg.includes('ad-score.com')
    // CefSharp-based crawlers (for example the Microsoft Outlook Safe Links
    // scanner) reject with this internal message when they fail to resolve a
    // JS object. The trailing Id/MethodName/ParamCount values vary, so match
    // the stable prefix only.
    || msg.includes('Object Not Found Matching Id')
  ) {
    return true;
  }

  if (typeof navigator !== 'undefined' && navigator.userAgent) {
    if (navigator.userAgent.includes('DuckDuckBot')
      || navigator.userAgent.includes('GoogleOther')
      || navigator.userAgent.includes('Googlebot')
      || navigator.userAgent.includes('google.com/bot.html')
    ) {
      return true;
    }
  }

  return false;
};

export const _attachGlobalErrorListeners = (callback) => () => {
  window.addEventListener('error', (event) => {
    let msg = event.message || 'Unknown error';
    
    if (event.error && event.error.stack) {
      msg += '\n\nStack:\n' + event.error.stack;
    }

    if (_isBlacklistedError("")(msg)()) return;

    callback(window.location.href)(msg)(); 
  });
  window.addEventListener('unhandledrejection', (event) => {
    let msg = 'Unhandled rejection';
    if (event.reason) {
      if (event.reason.message) msg = event.reason.message;
      else msg = String(event.reason);
      
      if (event.reason.stack) {
        msg += '\n\nStack:\n' + event.reason.stack;
      }
    }

    if (_isBlacklistedError("")(msg)()) return;
    
    callback(window.location.href)(msg)();
  });
};
