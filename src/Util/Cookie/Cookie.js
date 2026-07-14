import cookie from "cookie";

export const parse = (str) => {
  return cookie.parse(str);
};

export const serializeImpl = (name) => (val) => (options) => {
  return cookie.serialize(name, val, options);
};
