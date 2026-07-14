export const initFirefly = (varXName) => (varYName) => (satelliteVarXName) => (satelliteVarYName) => (satelliteClass) => (el) => () => {
  const container = el.parentElement;

  if (!container) return () => {};

  let mouseX = window.innerWidth / 2;
  let mouseY = window.innerHeight / 2;

  let elX = mouseX;
  let elY = mouseY;

  let isHovering = false;
  let firstMove = false;
  let animationFrameId = null;

  let lastX = 0;
  let lastY = 0;
  let satellitesUpdateNeeded = true;
  let lastSatelliteUpdate = 0;

  // Event listeners only capture the intention (or where the mouse is).
  // They do not perform any direct visual rendering to avoid jitters.
  const onMouseMove = (e) => {
    // Mise à jour de la "cible" que l'élément doit atteindre
    mouseX = e.clientX;
    mouseY = e.clientY;

    if (!firstMove) {
      // On first move, the element "jumps" directly to the mouse position
      // without interpolation animation to avoid traversing the screen
      elX = mouseX;
      elY = mouseY;

      firstMove = true;
      el.style.opacity = '1';
    } else if (!isHovering) {
       isHovering = true;
       el.style.opacity = '1';
    }
  };

  const onScrollOrResize = () => {
    satellitesUpdateNeeded = true;
  };

  const update = (timestamp) => {
    const currentTimestamp = timestamp || performance.now();

    if (satellitesUpdateNeeded && (currentTimestamp - lastSatelliteUpdate > 150)) {
      updateSatellites();
      lastSatelliteUpdate = currentTimestamp;
    }

    if (firstMove) {
      // Linear interpolation (Lerp)
      // We gradually bring elX closer to mouseX (the target) by 15% each frame.
      // This creates the elastic "smooth follow" effect (ease-out).
      elX += (mouseX - elX) * 0.15;
      elY += (mouseY - elY) * 0.15;

      const delta = Math.abs(elX - lastX) + Math.abs(elY - lastY);

      // Zeno's paradox bailout: Only update DOM if movement is significant (> 0.1px)
      if (delta > 0.1) {
        // Apply CSS transformation. Using `translate3d` often forces the browser
        // to use hardware acceleration (GPU)
        el.style.transform = `translate3d(calc(${elX}px - 50%), calc(${elY}px - 50%), 0)`;
        
        document.body.style.setProperty(varXName, `${elX}px`);
        document.body.style.setProperty(varYName, `${elY}px`);

        lastX = elX;
        lastY = elY;
      }
    }

    // Registered for the next frame (infinite loop as long as the component is mounted)
    animationFrameId = window.requestAnimationFrame(update);
  };
  
  const updateSatellites = () => {
    const satellites = document.querySelectorAll(`.${satelliteClass}`);

    // Read all layouts first to prevent layout thrashing
    const layouts = Array.from(satellites).map(satellite => {
      const rect = satellite.getBoundingClientRect();

      return {
        el: satellite,
        cx: rect.left + rect.width / 2,
        cy: rect.top + rect.height / 2
      };
    });

    // Write all styles
    layouts.forEach(sat => {
      sat.el.style.setProperty(satelliteVarXName, `${sat.cx}px`);
      sat.el.style.setProperty(satelliteVarYName, `${sat.cy}px`);
    });

    satellitesUpdateNeeded = false;
  };

  window.addEventListener('mousemove', onMouseMove, { capture: true, passive: true });

  window.addEventListener('resize', onScrollOrResize, { passive: true });
  window.addEventListener('scroll', onScrollOrResize, { capture: true, passive: true });
  
  // MutationObserver to automatically detect DOM changes (Halogen rerender, routing, async loads)
  // and trigger a satellite coordinate recalculation on the next animation frame.
  const observer = new MutationObserver(() => {
    onScrollOrResize();
  });

  // Observe the body for node additions/removals and class/style changes
  observer.observe(document.body, { 
    childList: true, 
    subtree: true,
    attributes: true,
    attributeFilter: ['class', 'style']
  });

  // Start the animation loop
  animationFrameId = window.requestAnimationFrame(update);

  // Cleanup function called by PureScript
  // Vital to avoid memory leaks.
  return () => {
    window.removeEventListener('mousemove', onMouseMove, { capture: true, passive: true });
    
    window.removeEventListener('resize', onScrollOrResize, { passive: true });
    window.removeEventListener('scroll', onScrollOrResize, { capture: true, passive: true });

    observer.disconnect();

    if (animationFrameId !== null) {
      window.cancelAnimationFrame(animationFrameId);
    }
  };
};
