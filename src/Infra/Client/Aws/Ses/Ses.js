import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";

// These SDK operations cannot be aborted through the previous Promise bridge.
const runAsync = (operation) => (onError, onSuccess) => {
  operation().then(onSuccess, onError);
  return (_cancelError, _onCancelError, onCancelSuccess) => onCancelSuccess();
};

export const _createInnerClient = (
  region,
  accessKeyId,
  secretAccessKey,
) => {
  return new SESClient({
    region,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });
};

export const _sendMailImpl = (client) => (fromName) => (fromEmail) =>
  (toName) => (toEmail) => (subject) => (text) => (html) =>
  runAsync(async () => {
    const body = {};
    if (html) {
      body.Html = { Charset: "UTF-8", Data: html };
    }
    if (text) {
      body.Text = { Charset: "UTF-8", Data: text };
    }

    const command = new SendEmailCommand({
      Destination: {
        ToAddresses: [`${toName} <${toEmail}>`],
      },
      Message: {
        Body: body,
        Subject: {
          Charset: "UTF-8",
          Data: subject,
        },
      },
      Source: `${fromName} <${fromEmail}>`,
      // ReplyToAddresses: [from],
    });

    const logContent = html || text || "";
    console.log(
      `Sending email from: ${command.input.Source} to: ${command.input.Destination.ToAddresses} with subject: ${command.input.Message.Subject.Data}\nContent: ${logContent}`,
    );

    await client.send(command);
  });
