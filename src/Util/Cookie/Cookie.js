import cookie from "cookie";

export const parse = (str) => {
  return cookie.parse(str);
};

export const serializeImpl =
  (name) =>
  (val) =>
  (maxAge) =>
  (httpOnly) =>
  (path) =>
  (secure) =>
  (sameSite) =>
  (domain) =>
    cookie.serialize(name, val, { maxAge, httpOnly, path, secure, sameSite, domain });
