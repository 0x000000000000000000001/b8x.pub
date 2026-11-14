
export const runWithWebLockImpl = function(actionPromiseEffect) {
  return function() {
    if (typeof navigator !== 'undefined' && navigator.locks) {
      return navigator.locks.request('auth_refresh_lock', function() {
        return actionPromiseEffect();
      });
    } else {
      return actionPromiseEffect();
    }
  };
};
