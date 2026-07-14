export const _setInterval = (ms) => (fn) => () => {
  const id = global.setInterval(fn, ms);
  if (id.ref) {
    id.ref();
  }
  return id;
};

export const _clearInterval = (id) => () => {
  if (id.unref) {
    id.unref();
  }
  global.clearInterval(id);
};