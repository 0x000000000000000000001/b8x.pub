export function parseJSONImpl(left) {
  return function (right) {
    return function (str) {
      try {
        return right(JSON.parse(str));
      } catch (e) {
        return left(e.toString());
      }
    };
  };
}
