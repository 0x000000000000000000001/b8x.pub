// Run with: node --experimental-vm-modules test/ffi/clients.mjs
// Synthetic SDK modules ensure these checks never reach a network service.
import assert from "node:assert/strict";
import crypto from "node:crypto";
import { readFile } from "node:fs/promises";
import vm from "node:vm";

let checks = 0;
const check = (condition, message) => {
  assert.ok(condition, message);
  checks++;
};
const context = vm.createContext({ Buffer, console: { log() {}, error() {} } });
async function loadClient(path, dependencies) {
  const module = new vm.SourceTextModule(
    await readFile(
      new URL(`../../src/Infra/Client/${path}.js`, import.meta.url),
      "utf8",
    ),
    { context },
  );
  await module.link((name) => {
    const exports = dependencies[name];
    assert.ok(exports, `Unexpected SDK import ${name}`);
    return new vm.SyntheticModule(
      Object.keys(exports),
      function () {
        for (const [key, value] of Object.entries(exports))
          this.setExport(key, value);
      },
      { context },
    );
  });
  await module.evaluate();
  return module.namespace;
}
function runOperation(operation, cancel = false) {
  return new Promise((resolve, reject) => {
    const canceler = operation(reject, resolve);
    check(
      typeof canceler === "function",
      "Aff registration returns a canceler",
    );
    if (cancel) {
      let finished = false;
      canceler(new Error("cancel"), reject, () => {
        finished = true;
      });
      check(finished, "No-op cancellation completes synchronously");
    }
  });
}
class Command {
  constructor(input) {
    this.input = input;
  }
}
class Client {
  constructor(options) {
    this.options = options;
  }
}

const ses = await loadClient("Aws/Ses/Ses", {
  "@aws-sdk/client-ses": { SESClient: Client, SendEmailCommand: Command },
});
const mail = ses._createInnerClient("region", "key", "secret");
check(mail.options.credentials.accessKeyId === "key", "SES credentials");
const sent = [];
mail.send = async (command) => {
  sent.push(command);
  return { MessageId: "id" };
};
const sendMail = ses._sendMailImpl(mail)("Sender")("sender@example.test")(
  "Recipient",
)("recipient@example.test")("Subject")("Hello")("<p>Hello</p>");
check(sent.length === 0, "Constructing SES Aff has no SDK effect");
check((await runOperation(sendMail, true)) === undefined, "SES result is Unit");
check(
  sent[0].input.Destination.ToAddresses[0] ===
    "Recipient <recipient@example.test>",
  "SES address",
);
check(sent[0].input.Source === "Sender <sender@example.test>", "SES source");
check(sent[0].input.Message.Subject.Data === "Subject", "SES subject");
check(sent[0].input.Message.Body.Text.Data === "Hello", "SES text");
check(sent[0].input.Message.Body.Html.Data === "<p>Hello</p>", "SES HTML");
const sdkError = new Error("SDK error");
mail.send = async () => {
  throw sdkError;
};
await assert.rejects(runOperation(sendMail), (error) => error === sdkError);
checks++;

const nodemailer = await loadClient("Nodemailer/Nodemailer", {
  nodemailer: {
    default: {
      createTransport: (options) => ({ options, sendMail: async (message) => message }),
      createTestAccount: async () => ({
        smtp: { host: "mail.test", port: 465, secure: true },
        user: "test-user", pass: "test-pass",
      }),
    },
  },
});
const transport = nodemailer._createTransport("smtp.test")(587)("user")("pass")();
check(
  transport.options.host === "smtp.test" && transport.options.port === 587 &&
    transport.options.auth.user === "user" && transport.options.auth.pass === "pass",
  "Nodemailer SMTP settings and credentials",
);
const testTransport = await nodemailer._createTestTransport();
check(testTransport.options.secure === true, "Nodemailer test account TLS setting");
const messageOptions = await nodemailer._sendMail(transport)("sender")("recipient")(
  "subject",
)("text")("<b>html</b>")("reply-to")();
assert.deepEqual({ ...messageOptions }, {
  from: "sender", to: "recipient", subject: "subject",
  text: "text", html: "<b>html</b>", replyTo: "reply-to",
});
checks++;

const events = [];
let consumer;
const channel = {
  assertQueue: async (queue, options) => {
    events.push(["declare", queue, options]);
  },
  sendToQueue: (queue, content, options) => {
    events.push(["publish", queue, content, options]);
    return true;
  },
  consume: async (queue, callback) => {
    consumer = callback;
  },
  ack: (message) => {
    events.push(["ack", message]);
  },
  close: async () => {
    events.push(["close-channel"]);
  },
};
const connection = {
  createChannel: async () => channel,
  close: async () => {
    events.push(["close-connection"]);
  },
};
const rabbit = await loadClient("RabbitMq/RabbitMq", {
  amqplib: {
    default: {
      connect: async (options) => {
        events.push(["connect", options]);
        return connection;
      },
    },
  },
});
const connect =
  rabbit._createConnectionImpl("localhost")(5672)("user")("password");
check(events.length === 0, "Constructing RabbitMQ Aff has no SDK effect");
check(
  (await runOperation(connect)) === connection,
  "Connection is delivered directly",
);
check(
  events[0][1].hostname === "localhost" && events[0][1].vhost === "/",
  "Connection options",
);
check(
  (await runOperation(rabbit._createChannelImpl(connection))) === channel,
  "Channel is delivered directly",
);
await runOperation(rabbit._assertQueueImpl(channel)("queue"));
check(events.at(-1)[2].durable, "Durable queue");
await runOperation(rabbit._sendToQueueImpl(channel)("queue")("body"));
check(
  events.at(-1)[2].toString() === "body" && events.at(-1)[3].persistent,
  "Persistent message body",
);
await runOperation(
  rabbit._consumeImpl(channel)("queue")((body) =>
    events.push(["message", body]),
  ),
);
const message = { content: Buffer.from("payload") };
consumer(message);
check(
  events.at(-2)[0] === "message" && events.at(-1)[0] === "ack",
  "Direct callback precedes acknowledgement",
);
const count = events.length;
consumer(null);
check(events.length === count, "Cancelled consumer messages are ignored");
await runOperation(
  rabbit._consumeImpl(channel)("queue")(() => {
    throw sdkError;
  }),
);
assert.throws(
  () => consumer(message),
  (error) => error === sdkError,
);
checks++;
check(events.length === count, "Failed callback is not acknowledged");
channel.sendToQueue = () => false;
await assert.rejects(
  runOperation(rabbit._sendToQueueImpl(channel)("queue")("body")),
  /Failed to send/,
);
checks++;
channel.assertQueue = async () => {
  throw sdkError;
};
await assert.rejects(
  runOperation(rabbit._assertQueueImpl(channel)("queue")),
  (error) => error === sdkError,
);
checks++;
await runOperation(rabbit._closeChannelImpl(channel));
await runOperation(rabbit._closeConnectionImpl(connection));
check(
  events.at(-2)[0] === "close-channel" &&
    events.at(-1)[0] === "close-connection",
  "Handles close",
);

class HeadCommand extends Command {}
class PutCommand extends Command {}
const images = [];
class FakeDom {
  static fragment(content) {
    const element = {
      tagName: "IMG",
      getAttribute() {
        return "/image.png";
      },
      setAttribute(name, value) {
        this.url = value;
      },
    };
    images.push(element);
    return {
      querySelectorAll() {
        return [element];
      },
      element,
    };
  }
  constructor() {
    this.window = {
      document: {
        createElement() {
          return {
            appendChild(fragment) {
              this.innerHTML = `<img src="${fragment.element.url}">`;
            },
          };
        },
      },
    };
  }
}
let downloads = 0;
context.fetch = async (url) => {
  downloads++;
  return {
    ok: true,
    arrayBuffer: async () => Uint8Array.of(1, 2, 3).buffer,
    headers: { get: () => "image/png" },
  };
};
const s3 = await loadClient("Aws/S3/S3", {
  "@aws-sdk/client-s3": {
    S3Client: Client,
    PutObjectCommand: PutCommand,
    HeadObjectCommand: HeadCommand,
  },
  "image-size": { default: () => ({ width: 1, height: 1, type: "png" }) },
  "node:crypto": { default: crypto },
  sharp: {
    default: (buffer) => ({
      trim() {
        return this;
      },
      toBuffer: async () => buffer,
    }),
  },
  jsdom: { JSDOM: FakeDom },
});
const storage = s3._createInnerClient("region", "key", "secret");
const writes = [];
let exists = false;
storage.send = async (command) => {
  if (command instanceof HeadCommand && !exists)
    throw Object.assign(new Error("missing"), { name: "NotFound" });
  if (command instanceof PutCommand) writes.push(command.input);
};
const upload = s3._uploadUrlContentImpl(storage)("bucket")(true)("images")(
  false,
)(false)("https://example.test/image.png")(() => "png");
check(downloads === 0, "Constructing S3 Aff does not download");
const result = await runOperation(upload);
check(
  result.dimensions.width === 1 && result.mimeType === "image/png",
  "S3 result record",
);
check(
  writes.length === 1 && writes[0].Key === result.src,
  "Missing S3 object uploaded",
);
exists = true;
await runOperation(upload);
check(writes.length === 1, "Existing S3 object reused");
const html = await runOperation(
  s3._uploadHtmlUrlContentsImpl(storage)("bucket")(true)("images")(() => "png")(
    false,
  )("https://host.test")("https://legacy.test")('<img src="/image.png">'),
);
check(
  html === `<img src="${result.src}">`,
  "HTML uploads use the ordinary async uploader",
);
context.fetch = async () => {
  throw sdkError;
};
await assert.rejects(runOperation(upload), (error) => error === sdkError);
checks++;
console.log(`${checks} JavaScript client FFI checks passed`);
