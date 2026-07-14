export const empty = {};

export const _on = function(tag) {
  return function(handler) {
    return function(dict) {
      var newDict = {};
      for (var k in dict) {
        if (Object.prototype.hasOwnProperty.call(dict, k)) {
          newDict[k] = dict[k];
        }
      }
      newDict[tag] = handler;
      return newDict;
    };
  };
};

export const build = function(dict) {
  return function(fallback) {
    return function(variant) {
      var handler = dict[variant.type];
      if (handler !== undefined) {
        return handler(variant.value);
      } else {
        return fallback(variant);
      }
    };
  };
};

