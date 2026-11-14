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

export const _build = function(dict) {
  return function(fallback) {
    return function(tag) {
      return function(value) {
        return function(original) {
          var handler = dict[tag];
          if (handler !== undefined) {
            return handler(value);
          } else {
            return fallback(original);
          }
        };
      };
    };
  };
};

