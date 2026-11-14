export const getCsrfToken = () => {
  if (typeof document === 'undefined') return "";
  const match = document.cookie.match(new RegExp('(^| )csrf_token=([^;]+)'));
  if (match) return match[2];
  return "";
};
