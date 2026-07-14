export const fixTaggedSumRepMissingValue = (f) => {
  if (f && typeof f === "object" && !Array.isArray(f)) {
    if (typeof f.type === "string" && !("value" in f)) {
      return Object.assign({}, f, { value: undefined });
    }
  }
  return f;
};
