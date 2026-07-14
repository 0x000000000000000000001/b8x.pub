export const removeAccents = (str) => str.normalize("NFD").replace(/[\u0300-\u036f]/g, "");

export const upperCaseFirst = (str) => {
  if (!str) return str;
  return str.charAt(0).toUpperCase() + str.slice(1);
};

export const lowerCaseFirst = (str) => {
  if (!str) return str;
  return str.charAt(0).toLowerCase() + str.slice(1);
};
