export const _getRootFontSize = () => {
  const rootElement = document.documentElement;
  const computedStyle = window.getComputedStyle(rootElement);
  const fontSize = computedStyle.fontSize;
  
  return parseFloat(fontSize);
};
