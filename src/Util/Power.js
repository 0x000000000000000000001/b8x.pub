export const isPowerful = (() => {
  if (typeof navigator !== 'undefined' && navigator.hardwareConcurrency && navigator.hardwareConcurrency <= 4) return false;
  if (typeof navigator !== 'undefined' && navigator.deviceMemory && navigator.deviceMemory <= 4) return false;
  if (typeof window !== 'undefined' && window.matchMedia && window.matchMedia('(prefers-reduced-transparency: reduce)').matches) return false;
  return true;
})();
