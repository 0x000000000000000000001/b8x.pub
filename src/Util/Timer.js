export const setIntervalImpl = (ms, fn) => {
  const id = global.setInterval(fn, ms);
  if (id.ref) {
    id.ref();
  }
  return id;
};

export const clearIntervalImpl = (id) => {
  if (id.unref) {
    id.unref();
  }
  global.clearInterval(id);
};
