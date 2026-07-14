export const appendHeaderImpl = (name) => (value) => (msg) => () => {
  msg.appendHeader(name, value);
};

export const nowIso = () => new Date().toISOString();
