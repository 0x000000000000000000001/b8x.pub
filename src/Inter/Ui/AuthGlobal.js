export const _exposeAuth = (loginFn) => (registerFn) => () => {
  window.login = (email) => {
    loginFn(email)();
    console.log("Login request sent for " + email);
  };
  window.registerUser = (email) => {
    registerFn(email)();
    console.log("Register request sent for " + email);
  };
  window.logout = async () => {
    try {
      await fetch('/api/auth/logout', { method: 'POST', headers: { 'Accept': 'application/json' } });
      // console.log('Logout request sent, reloading...');
      // window.location.reload();
    } catch (e) {
      console.error(e);
    }
  };
  window.isLoggedIn = () => {
    return document.cookie.includes("refresh_token_trace=1");
  };
};

export const isLoggedIn = () => {
  return document.cookie.includes("refresh_token_trace=1");
};
