export function observeTargetImpl(selector) {
  return function(callback) {
    return function() {
      var animationFrameId = null;
      var lastCoords = { top: 0, left: 0, width: 0, height: 0, visible: false };
      
      function checkTarget() {
        var el = document.querySelector(selector);
        var visible = false;
        var top = 0;
        var left = 0;
        var width = 0;
        var height = 0;
        
        if (el) {
          var rect = el.getBoundingClientRect();
          if (rect.width > 0 && rect.height > 0) {
            visible = true;
            top = rect.top;
            left = rect.left;
            width = rect.width;
            height = rect.height;
          }
        }
        
        if (visible !== lastCoords.visible || 
            Math.abs(top - lastCoords.top) > 0.5 || 
            Math.abs(left - lastCoords.left) > 0.5 || 
            Math.abs(width - lastCoords.width) > 0.5 || 
            Math.abs(height - lastCoords.height) > 0.5) {
          lastCoords = { top: top, left: left, width: width, height: height, visible: visible };
          callback(top)(left)(width)(height)(visible)();
        }
        
        animationFrameId = requestAnimationFrame(checkTarget);
      }
      
      animationFrameId = requestAnimationFrame(checkTarget);
      
      return function() {
        if (animationFrameId !== null) {
          cancelAnimationFrame(animationFrameId);
        }
      };
    };
  };
}
