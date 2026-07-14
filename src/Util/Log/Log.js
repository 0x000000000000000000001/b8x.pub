export const _write = (str) => () => {
  process.stdout.write(str);
};