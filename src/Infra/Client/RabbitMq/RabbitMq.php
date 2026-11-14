<?php

// SDK operations start when Aff registers its callbacks. Cancellation does not
// abort these operations, matching the previous Promise adapter.
$runAsync = static function (callable $operation): \Closure {
    return static function (callable $onError, callable $onSuccess) use ($operation): \Closure {
        \Amp\async(static function () use ($operation, $onError, $onSuccess): void {
            try {
                $result = $operation();
            } catch (\Throwable $error) {
                $onError($error);
                return;
            }
            $onSuccess($result);
        });
        return static function ($cancelError, $onCancelError, $onCancelSuccess): void {
            $onCancelSuccess(null);
        };
    };
};

$exports['_createConnectionImpl'] = static function ($host, $port, $user, $password) use (
    $runAsync,
) {
    return $runAsync(static function () use ($host, $port, $user, $password) {
        return new \PhpAmqpLib\Connection\AMQPStreamConnection($host, $port, $user, $password);
    });
};

$exports['_createChannelImpl'] = static function ($connection) use ($runAsync) {
    return $runAsync(static function () use ($connection) {
        return $connection->channel();
    });
};

$exports['_assertQueueImpl'] = static function ($channel, $queue) use ($runAsync) {
    return $runAsync(static function () use ($channel, $queue) {
        $channel->queue_declare($queue, false, true, false, false);
        return null;
    });
};

$exports['_sendToQueueImpl'] = static function ($channel, $queue, $content) use ($runAsync) {
    return $runAsync(static function () use ($channel, $queue, $content) {
        $message = new \PhpAmqpLib\Message\AMQPMessage($content, [
            'delivery_mode' => \PhpAmqpLib\Message\AMQPMessage::DELIVERY_MODE_PERSISTENT,
        ]);
        $channel->basic_publish($message, '', $queue);
        return null;
    });
};

$exports['_consumeImpl'] = static function ($channel, $queue, $onMessage) use ($runAsync) {
    return $runAsync(static function () use ($channel, $queue, $onMessage) {
        $channel->basic_consume($queue, '', false, false, false, false, static function (
            $message,
        ) use ($onMessage) {
            $onMessage($message->body);
            $message->ack();
        });

        if (class_exists('\\Revolt\\EventLoop')) {
            $socket = $channel->getConnection()->getIO()->getSocket();
            \Revolt\EventLoop::onReadable($socket, static function ($watcherId, $socket) use (
                $channel,
            ) {
                try {
                    while (true) {
                        $channel->wait(null, true);
                    }
                } catch (\PhpAmqpLib\Exception\AMQPTimeoutException $error) {
                    // No more frames are available; yield to the event loop.
                } catch (\Exception $error) {
                    \Revolt\EventLoop::cancel($watcherId);
                }
            });
        }
        return null;
    });
};

$exports['_closeConnectionImpl'] = static function ($connection) use ($runAsync) {
    return $runAsync(static function () use ($connection) {
        $connection->close();
        return null;
    });
};

$exports['_closeChannelImpl'] = static function ($channel) use ($runAsync) {
    return $runAsync(static function () use ($channel) {
        $channel->close();
        return null;
    });
};

return $exports;
