export const getLocalStorageOrFallback = function() {
  try {
    var s = window.localStorage;
    s.getItem('__test__');
    return s;
  } catch (e) {
    if (!window.__memoryStorageFallback) {
      window.__memoryStorageFallback = {};
    }
    return {
      getItem: function(key) {
        return Object.prototype.hasOwnProperty.call(window.__memoryStorageFallback, key) ? window.__memoryStorageFallback[key] : null;
      },
      setItem: function(key, value) {
        window.__memoryStorageFallback[key] = String(value);
      },
      removeItem: function(key) {
        delete window.__memoryStorageFallback[key];
      },
      clear: function() {
        window.__memoryStorageFallback = {};
      },
      key: function(index) {
        return Object.keys(window.__memoryStorageFallback)[index] || null;
      },
      get length() {
        return Object.keys(window.__memoryStorageFallback).length;
      }
    };
  }
};
