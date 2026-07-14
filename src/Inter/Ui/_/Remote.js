export const getCsrfToken = () => {
  if (typeof document === 'undefined') return "";
  const match = document.cookie.match(new RegExp('(^| )csrf_token=([^;]+)'));
  if (match) return match[2];
  return "";
};

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
