export const _dispatchPopStateEvent = () => {
  window.dispatchEvent(new PopStateEvent('popstate', { state: {} }));
};
