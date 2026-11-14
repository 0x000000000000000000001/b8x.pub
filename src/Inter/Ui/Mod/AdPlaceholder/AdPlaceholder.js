export function observeAdSizeImpl(idName) {
  return function(callback) {
    return function() {
      var lastW = -1;
      var lastH = -1;
      var observedNodes = new Set();
      
      var resObserver = typeof ResizeObserver !== "undefined" ? new ResizeObserver(function(entries) {
        checkSize();
      }) : null;

      var checkSize = function() {
        var target = document.getElementById(idName);
        if (!target) return;
        
        // Find iframe first, fallback to firstElementChild
        var adNode = target.querySelector('iframe') || target.firstElementChild;
        if (!adNode) return;

        if (resObserver && !observedNodes.has(adNode)) {
          observedNodes.add(adNode);
          resObserver.observe(adNode);
        }

        var rect = adNode.getBoundingClientRect();
        if (rect.width > 0 && rect.height > 0) {
          if (rect.width !== lastW || rect.height !== lastH) {
            lastW = rect.width;
            lastH = rect.height;
            callback(rect.width)(rect.height)();
          }
        }
      };

      var mutObserver = new MutationObserver(function(mutations) {
        setTimeout(checkSize, 50);
      });

      var timeoutId;
      var attempt = function() {
        var target = document.getElementById(idName);
        if (target) {
          mutObserver.observe(target, { childList: true, subtree: true, attributes: true });
          checkSize();
          setTimeout(checkSize, 500);
          setTimeout(checkSize, 2000);
        } else {
          timeoutId = setTimeout(attempt, 100);
        }
      };
      attempt();

      return function() {
        mutObserver.disconnect();
        if (resObserver) resObserver.disconnect();
        clearTimeout(timeoutId);
        observedNodes.clear();
      };
    };
  };
}
