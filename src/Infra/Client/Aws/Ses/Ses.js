import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";

export const _createInnerClient =
  (region) => (accessKeyId) => (secretAccessKey) => () => {
    return new SESClient({
      region,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
    });
  };

export const _sendMailImpl = (newPromise) => (client) => (options) => () => {
  return newPromise((resolve, reject) => {
    (async () => {
      const { from, to, subject, html, text } = options;

      const body = {};
      if (html) {
        body.Html = { Charset: "UTF-8", Data: html };
      }
      if (text) {
        body.Text = { Charset: "UTF-8", Data: text };
      }

      const command = new SendEmailCommand({
        Destination: {
          ToAddresses: [`${to.name} <${to.email}>`],
        },
        Message: {
          Body: body,
          Subject: {
            Charset: "UTF-8",
            Data: subject,
          },
        },
        Source: `${from.name} <${from.email}>`,
        // ReplyToAddresses: [from],
      });

      return await client.send(command);
    })()
      .then(resolve)
      .catch(reject);
  });
};
