if (typeof window !== 'undefined') {
  try {
    window.adFree = window.localStorage.getItem('b8x.adFree') === '1';
  } catch (e) {}
}

// Sddan's CMP sets `window.__gpp = undefined` when it fails to load, while GPT
// (loaded via AnyManager) caches that `__gpp` was a function and calls it later
// without re-checking, crashing with "output error: (0,a.__gpp) is not a function".
// Keep `__gpp` always callable so GPT can never hit an undefined API.
var _installGppGuard = function () {
  if (typeof window === 'undefined' || window.__gppGuardInstalled) return;
  window.__gppGuardInstalled = true;

  try {
    if (window.ABconsentCMP && window.ABconsentCMP.gppDisabled === true && !('__gpp' in window)) return;

    var desc = Object.getOwnPropertyDescriptor(window, '__gpp');
    if (desc && !('value' in desc)) return;

    var impl = desc && typeof desc.value === 'function' ? desc.value : null;
    var stub = function () {
      (stub.q = stub.q || []).push(arguments);
    };
    stub.q = [];

    Object.defineProperty(window, '__gpp', {
      configurable: true,
      get: function () { return typeof impl === 'function' ? impl : stub; },
      set: function (value) {
        if (typeof value === 'function') impl = value;
        else if (value === undefined || value === null) impl = null;
      }
    });
  } catch (e) {}
};

export const _ensureAds = () => {
  if (typeof window !== 'undefined') {
    try {
      if (window.localStorage.getItem('b8x.adFree') === '1') return;
    } catch (e) {}
  }

  if (typeof window === 'undefined') return;

  if (!window.ayManagerScriptInjected) {
    _installGppGuard();
    
    window.ayManagerScriptInjected = true;
    
    var stub = document.createElement('script');
    stub.src = "https://cache.consentframework.com/js/pa/36289/c/3Qfau/stub";
    stub.async = false;
    document.head.appendChild(stub);

    var cmp = document.createElement('script');
    cmp.src = "https://choices.consentframework.com/js/pa/36289/c/3Qfau/cmp";
    cmp.async = false;
    document.head.appendChild(cmp);

    var ad = document.createElement('script');
    ad.src = "https://akAGs7PS6LNtjMJnJ.ay.delivery/manager/akAGs7PS6LNtjMJnJ";
    ad.async = false;
    ad.referrerPolicy = "no-referrer-when-downgrade";
    document.head.appendChild(ad);
  }

  var checkManager = function() {
    if (window.ayManagerEnv && typeof window.ayManagerEnv.changePage === 'function') {
      window.ayManagerEnv.changePage();
    } else {
      setTimeout(checkManager, 500);
    }
  };
  
  checkManager();
};

export const _setAdFree = (isAdFree) => () => {
  if (typeof window !== 'undefined') {
    try {
      if (isAdFree) {
        window.localStorage.setItem('b8x.adFree', '1');
      } else {
        window.localStorage.removeItem('b8x.adFree');
      }
    } catch (e) {}
    
    if (isAdFree) {
      var sticky = document.getElementById('aymStickyFooter');
      if (sticky) sticky.remove();
      var msna = document.getElementById('msna-ad');
      if (msna) msna.remove();
      var interstitials = document.querySelectorAll('ins[id*="interstitiel"]');
      if (interstitials) {
        interstitials.forEach(function(el) { el.remove(); });
      }
      var caligo = document.querySelectorAll('[data-test*="caligo-bubble"]');
      if (caligo) {
        caligo.forEach(function(el) { el.remove(); });
      }
      
      if (!window.adFreeStyleInjected) {
        window.adFreeStyleInjected = true;
        var style = document.createElement('style');
        style.id = 'b8x-ad-free-style';
        style.innerHTML = '#aymStickyFooter, #msna-ad, ins[id*="interstitiel"], [data-test*="caligo-bubble"], [class*="msna-native-"] { display: none !important; }';
        document.head.appendChild(style);
      }

      if (window.googletag && window.googletag.apiReady) {
        window.googletag.destroySlots();
      }
    } else {
      if (window.adFreeStyleInjected) {
        window.adFreeStyleInjected = false;
        var style = document.getElementById('b8x-ad-free-style');
        if (style) style.remove();
      }
      
      _ensureAds();
    }
  }
};

export const _getAdFree = () => {
  if (typeof window !== 'undefined') {
    try {
      return window.localStorage.getItem('b8x.adFree') === '1';
    } catch (e) {
      return false;
    }
  }
  return false;
};

