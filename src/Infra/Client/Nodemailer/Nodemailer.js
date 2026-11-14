import nodemailer from "nodemailer";

function createTransport(host, port, user, pass, secure) {
  const transportConfig = {
    pool: true, // See https://nodemailer.com/smtp#2-pooled-connections
    host,
    port,
    secure,
    auth: {
      user,
      pass,
    },
  };

  return nodemailer.createTransport(transportConfig);
}

export const _createTransport = (host) => (port) => (user) => (pass) => () =>
  createTransport(host, port, user, pass);

export const _createTestTransport = async () => {
  const testAccount = await nodemailer.createTestAccount();
  
  const host = testAccount.smtp.host;
  const port = testAccount.smtp.port;
  const secure = testAccount.smtp.secure;

  const user = testAccount.user;
  const pass = testAccount.pass;

  return createTransport(host, port, user, pass, secure);
};

export const _sendMail = (transport) => (from) => (to) => (subject) =>
  (text) => (html) => (replyTo) => async () => {
    const info = await transport.sendMail({ from, to, subject, text, html, replyTo });

    if (transport.options.host === 'smtp.ethereal.email') { // Test
      console.log("Message sent: %s", nodemailer.getTestMessageUrl(info));
    }

    return info;
  };
