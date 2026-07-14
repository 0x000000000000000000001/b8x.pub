import nodemailer from "nodemailer";

export const _createTransport = ({ host, port, secure, user, pass }) => () => {
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
};

export const _createTestTransport = async () => {
  const testAccount = await nodemailer.createTestAccount();
  
  const host = testAccount.smtp.host;
  const port = testAccount.smtp.port;
  const secure = testAccount.smtp.secure;

  const user = testAccount.user;
  const pass = testAccount.pass;

  return _createTransport({ host, port, secure, user, pass })();
};

export const _sendMail = (transport) => (options) => async () => {
  const info = await transport.sendMail(options);

  if (transport.options.host === 'smtp.ethereal.email') { // Test
    console.log("Message sent: %s", nodemailer.getTestMessageUrl(info));
  }

  return info;
};
