<?php

// Local SDK doubles: these checks never open a socket or send email.
namespace Amp {
    function async(callable $operation): void
    {
        $GLOBALS['clientTasks'][] = $operation;
    }
}
namespace Aws\Ses {
    class SesClient
    {
        public array $sent = [];
        public ?\Throwable $failure = null;
        public function __construct(public array $options) {}
        public function sendEmail(array $message): array
        {
            if ($this->failure) {
                throw $this->failure;
            }
            $this->sent[] = $message;
            return ['MessageId' => 'test'];
        }
    }
}
namespace Aws\S3\Exception {
    class S3Exception extends \Exception {}
}
namespace Aws\S3 {
    class S3Client
    {
        public array $writes = [];
        public bool $exists = false;
        public function __construct(public array $options) {}
        public function headObject(array $options): void
        {
            if (!$this->exists) {
                throw new \Aws\S3\Exception\S3Exception('missing');
            }
        }
        public function putObject(array $options): void
        {
            $this->writes[] = $options;
        }
    }
}
namespace Amp\Http\Client {
    class Request
    {
        public function __construct(public string $url) {}
        public function setHeader(string $name, string $value): void {}
    }
    class HttpClientBuilder
    {
        public static string $body = '';
        public static function buildDefault(): self
        {
            return new self();
        }
        public function request(Request $request): self
        {
            return $this;
        }
        public function getBody(): self
        {
            return $this;
        }
        public function buffer(): string
        {
            return self::$body;
        }
    }
}
namespace PhpAmqpLib\Message {
    class AMQPMessage
    {
        public const DELIVERY_MODE_PERSISTENT = 2;
        public int $acknowledgements = 0;
        public function __construct(public string $body, public array $options = []) {}
        public function ack(): void
        {
            $this->acknowledgements++;
        }
    }
}
namespace PhpAmqpLib\Connection {
    class AMQPStreamConnection
    {
        public static ?\Throwable $failure = null;
        public bool $closed = false;
        public \ClientTestChannel $testChannel;
        public array $options;
        public function __construct(...$options)
        {
            if (self::$failure) {
                throw self::$failure;
            }
            $this->options = $options;
            $this->testChannel = new \ClientTestChannel();
        }
        public function channel(): \ClientTestChannel
        {
            return $this->testChannel;
        }
        public function close(): void
        {
            $this->closed = true;
        }
    }
}
namespace {
    class ClientTestChannel
    {
        public array $calls = [];
        public $consumer;
        public ?\Throwable $failure = null;
        public function queue_declare(...$arguments): void
        {
            if ($this->failure) {
                throw $this->failure;
            }
            $this->calls[] = ['declare', $arguments];
        }
        public function basic_publish(...$arguments): void
        {
            $this->calls[] = ['publish', $arguments];
        }
        public function basic_consume(...$arguments): void
        {
            $this->consumer = array_pop($arguments);
            $this->calls[] = ['consume', $arguments];
        }
        public function close(): void
        {
            $this->calls[] = ['close'];
        }
    }
    $checks = 0;
    function check(bool $condition, string $message): void
    {
        global $checks;
        if (!$condition) {
            throw new \RuntimeException($message);
        }
        $checks++;
    }
    function loadClient(string $module): array
    {
        $exports = [];
        return require dirname(__DIR__, 2) . '/src/Infra/Client/' . $module . '.php';
    }
    function flushClientTasks(): void
    {
        while ($GLOBALS['clientTasks']) {
            array_shift($GLOBALS['clientTasks'])();
        }
    }
    function runClientOperation(callable $operation, bool $cancel = false): mixed
    {
        $settled = [];
        $canceler = $operation(
            static function ($error) use (&$settled): void {
                $settled[] = ['error', $error];
            },
            static function ($value) use (&$settled): void {
                $settled[] = ['success', $value];
            },
        );
        check($settled === [], 'SDK work must remain queued until the event loop executes it');
        if ($cancel) {
            $cancelled = false;
            $canceler(
                null,
                static function ($error): void {
                    throw $error;
                },
                static function ($unit) use (&$cancelled): void {
                    $cancelled = true;
                },
            );
            check($cancelled, 'No-op cancellation must complete');
        }
        flushClientTasks();
        check(count($settled) === 1, 'Every SDK operation must settle once');
        if ($settled[0][0] === 'error') {
            throw $settled[0][1];
        }
        return $settled[0][1];
    }
    function expectClientFailure(callable $operation, \Throwable $expected): void
    {
        try {
            runClientOperation($operation);
        } catch (\Throwable $actual) {
            check(
                $actual === $expected,
                'The original SDK exception must reach the error callback',
            );
            return;
        }
        throw new \RuntimeException('Expected SDK failure');
    }
    $GLOBALS['clientTasks'] = [];
    $ses = loadClient('Aws/Ses/Ses');
    $mail = $ses['_createInnerClient']('region', 'key', 'secret');
    check(
        $mail->options['credentials'] === ['key' => 'key', 'secret' => 'secret'],
        'SES credentials',
    );
    $operation = $ses['_sendMailImpl'](
        $mail,
        'Sender', 'sender@example.test',
        'Recipient', 'recipient@example.test',
        'Subject', 'Hello', '<p>Hello</p>',
    );
    check(
        $mail->sent === [] && $GLOBALS['clientTasks'] === [],
        'Constructing SES Aff must not start it',
    );
    check(runClientOperation($operation, true) === null, 'SES returns Unit');
    check(
        $mail->sent[0]['Destination']['ToAddresses'] === ['Recipient <recipient@example.test>'],
        'SES destination',
    );
    check($mail->sent[0]['Source'] === 'Sender <sender@example.test>', 'SES source');
    check($mail->sent[0]['Message']['Subject']['Data'] === 'Subject', 'SES subject');
    check($mail->sent[0]['Message']['Body']['Text']['Data'] === 'Hello', 'SES text');
    check($mail->sent[0]['Message']['Body']['Html']['Data'] === '<p>Hello</p>', 'SES HTML');
    $mail->failure = new \RuntimeException('SES unavailable');
    expectClientFailure($operation, $mail->failure);

    $rabbit = loadClient('RabbitMq/RabbitMq');
    $connectionOperation = $rabbit['_createConnectionImpl']('localhost', 5672, 'user', 'password');
    check($GLOBALS['clientTasks'] === [], 'Constructing RabbitMQ Aff must not start it');
    $connection = runClientOperation($connectionOperation);
    check($connection->options === ['localhost', 5672, 'user', 'password'], 'RabbitMQ credentials');
    $channel = runClientOperation($rabbit['_createChannelImpl']($connection));
    check($channel === $connection->testChannel, 'RabbitMQ channel');
    runClientOperation($rabbit['_assertQueueImpl']($channel, 'queue'));
    check(
        $channel->calls[0] === ['declare', ['queue', false, true, false, false]],
        'Queue is durable',
    );
    runClientOperation($rabbit['_sendToQueueImpl']($channel, 'queue', 'payload'));
    $message = $channel->calls[1][1][0];
    check(
        $message->body === 'payload' && $message->options['delivery_mode'] === 2,
        'Messages are persistent',
    );
    $received = [];
    runClientOperation(
        $rabbit['_consumeImpl']($channel, 'queue', static function ($body) use (&$received): void {
            $received[] = $body;
        }),
    );
    ($channel->consumer)($message);
    check(
        $received === ['payload'] && $message->acknowledgements === 1,
        'Native callback runs before acknowledgement',
    );
    $failure = new \RuntimeException('callback failure');
    runClientOperation(
        $rabbit['_consumeImpl']($channel, 'queue', static function ($body) use ($failure): void {
            throw $failure;
        }),
    );
    try {
        ($channel->consumer)($message);
    } catch (\Throwable $actual) {
        check($actual === $failure, 'Message error is preserved');
    }
    check($message->acknowledgements === 1, 'Failed message callback must not acknowledge');
    $channel->failure = new \RuntimeException('queue unavailable');
    expectClientFailure($rabbit['_assertQueueImpl']($channel, 'queue'), $channel->failure);
    runClientOperation($rabbit['_closeChannelImpl']($channel));
    runClientOperation($rabbit['_closeConnectionImpl']($connection));
    check($connection->closed && end($channel->calls) === ['close'], 'Client handles close');
    \PhpAmqpLib\Connection\AMQPStreamConnection::$failure = new \RuntimeException(
        'connection unavailable',
    );
    expectClientFailure(
        $connectionOperation,
        \PhpAmqpLib\Connection\AMQPStreamConnection::$failure,
    );

    $s3 = loadClient('Aws/S3/S3');
    check(
        array_keys($s3) === [
            '_createInnerClient',
            '_uploadUrlContentImpl',
            '_uploadHtmlUrlContentsImpl',
        ],
        'S3 exports match its foreign imports',
    );
    $storage = $s3['_createInnerClient']('region', 'key', 'secret');
    check(
        $storage->options['region'] === 'region',
        'S3 constructor matches the PureScript contract',
    );
    \Amp\Http\Client\HttpClientBuilder::$body = base64_decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
    );
    $upload = $s3['_uploadUrlContentImpl'](
        $storage,
        'bucket',
        true,
        'images',
        false,
        false,
        'https://example.test/image.png',
        static fn($mime) => 'png',
    );
    check(
        $storage->writes === [] && $GLOBALS['clientTasks'] === [],
        'Constructing S3 Aff must not start it',
    );
    $result = runClientOperation($upload);
    check(
        is_object($result) && $result->mimeType === 'image/png',
        'Upload returns a native record',
    );
    check(
        count($storage->writes) === 1 && $storage->writes[0]['Key'] === $result->src,
        'Missing object is uploaded',
    );
    check(
        $result->dimensions->width === 1 && $result->dimensions->height === 1,
        'Image dimensions are present without GD',
    );
    $storage->exists = true;
    runClientOperation($upload);
    check(count($storage->writes) === 1, 'Existing object is not uploaded again');
    $html = '<img src="https://example.test/image.png">';
    check(
        runClientOperation(
            $s3['_uploadHtmlUrlContentsImpl'](
                $storage,
                'bucket',
                true,
                'images',
                static fn($mime) => 'png',
                false,
                'host',
                'legacy',
                $html,
            ),
        ) === $html,
        'PHP retains its documented HTML pass-through',
    );
    \Amp\Http\Client\HttpClientBuilder::$body = '';
    try {
        runClientOperation($upload);
        throw new \RuntimeException('Expected empty download rejection');
    } catch (\Throwable $error) {
        check(
            str_contains($error->getMessage(), 'Failed to fetch image'),
            'Empty downloads reject',
        );
    }
    \Amp\Http\Client\HttpClientBuilder::$body = 'This is not an image';
    try {
        runClientOperation($upload);
        throw new \RuntimeException('Expected invalid dimensions rejection');
    } catch (\Throwable $error) {
        check(
            str_contains($error->getMessage(), 'Cannot determine image dimensions'),
            'Undetermined image dimensions reject',
        );
    }
    echo "$checks client FFI checks passed\n";
}
