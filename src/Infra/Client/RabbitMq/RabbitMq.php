<?php

$_createConnectionImpl = function($newPromise, $host = null, $port = null, $user = null, $password = null) use (&$_createConnectionImpl) {
    if (\func_num_args() < 5) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_createConnectionImpl) {
            return $_createConnectionImpl(...\array_merge($__args, $more));
        };
    }
    return function() use ($newPromise, $host, $port, $user, $password) {
        return $newPromise(function($resolve, $reject) use ($host, $port, $user, $password) {
            \Amp\async(function() use ($resolve, $reject, $host, $port, $user, $password) {
                try {
                    $conn = new \PhpAmqpLib\Connection\AMQPStreamConnection($host, $port, $user, $password);
                    $resolve($conn);
                } catch (\Throwable $e) {
                    $reject($e);
                }
            });
        });
    };
};
$exports['_createConnectionImpl'] = $_createConnectionImpl;

$_createChannelImpl = function($newPromise, $conn = null) use (&$_createChannelImpl) {
    if (\func_num_args() < 2) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_createChannelImpl) {
            return $_createChannelImpl(...\array_merge($__args, $more));
        };
    }
    return function() use ($newPromise, $conn) {
        return $newPromise(function($resolve, $reject) use ($conn) {
            \Amp\async(function() use ($resolve, $reject, $conn) {
                try {
                    $resolve($conn->channel());
                } catch (\Throwable $e) {
                    $reject($e);
                }
            });
        });
    };
};
$exports['_createChannelImpl'] = $_createChannelImpl;

$_assertQueueImpl = function($newPromise, $ch = null, $queue = null) use (&$_assertQueueImpl) {
    if (\func_num_args() < 3) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_assertQueueImpl) {
            return $_assertQueueImpl(...\array_merge($__args, $more));
        };
    }
    return function() use ($newPromise, $ch, $queue) {
        return $newPromise(function($resolve, $reject) use ($ch, $queue) {
            \Amp\async(function() use ($resolve, $reject, $ch, $queue) {
                try {
                    $ch->queue_declare($queue, false, true, false, false);
                    $resolve(null);
                } catch (\Throwable $e) {
                    $reject($e);
                }
            });
        });
    };
};
$exports['_assertQueueImpl'] = $_assertQueueImpl;

$_sendToQueueImpl = function($newPromise, $ch = null, $queue = null, $content = null) use (&$_sendToQueueImpl) {
    if (\func_num_args() < 4) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_sendToQueueImpl) {
            return $_sendToQueueImpl(...\array_merge($__args, $more));
        };
    }
    return function() use ($newPromise, $ch, $queue, $content) {
        return $newPromise(function($resolve, $reject) use ($ch, $queue, $content) {
            \Amp\async(function() use ($resolve, $reject, $ch, $queue, $content) {
                try {
                    $msg = new \PhpAmqpLib\Message\AMQPMessage($content, ['delivery_mode' => \PhpAmqpLib\Message\AMQPMessage::DELIVERY_MODE_PERSISTENT]);
                    $ch->basic_publish($msg, '', $queue);
                    $resolve(null);
                } catch (\Throwable $e) {
                    $reject($e);
                }
            });
        });
    };
};
$exports['_sendToQueueImpl'] = $_sendToQueueImpl;

$_consumeImpl = function($newPromise, $ch = null, $queue = null, $onMessage = null) use (&$_consumeImpl) {
    if (\func_num_args() < 4) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_consumeImpl) {
            return $_consumeImpl(...\array_merge($__args, $more));
        };
    }
    return function() use ($newPromise, $ch, $queue, $onMessage) {
        return $newPromise(function($resolve, $reject) use ($ch, $queue, $onMessage) {
            \Amp\async(function() use ($resolve, $reject, $ch, $queue, $onMessage) {
                try {
                    // Register consumer
                    $ch->basic_consume($queue, '', false, false, false, false, function($msg) use ($onMessage) {
                        $onMessage($msg->body)();
                        $msg->ack();
                    });
                    
                    // If Revolt is available, we watch the socket
                    if (class_exists('\\Revolt\\EventLoop')) {
                        $conn = $ch->getConnection();
                        $socket = $conn->getIO()->getSocket();
                        
                        \Revolt\EventLoop::onReadable($socket, function($callbackId, $socket) use ($ch) {
                            try {
                                // Non-blocking wait for frames/messages
                                // wait(null, true) returns immediately if no data is available
                                while (true) {
                                    $ch->wait(null, true);
                                }
                            } catch (\PhpAmqpLib\Exception\AMQPTimeoutException $e) {
                                // No more data available right now, return control to event loop
                            } catch (\Exception $e) {
                                // We should probably cancel the watcher if the channel/connection closes or errors out
                                \Revolt\EventLoop::cancel($callbackId);
                            }
                        });
                    }
                    
                    $resolve(null);
                } catch (\Throwable $e) {
                    $reject($e);
                }
            });
        });
    };
};
$exports['_consumeImpl'] = $_consumeImpl;

$_closeConnectionImpl = function($newPromise, $conn = null) use (&$_closeConnectionImpl) {
    if (\func_num_args() < 2) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_closeConnectionImpl) {
            return $_closeConnectionImpl(...\array_merge($__args, $more));
        };
    }
    return function() use ($newPromise, $conn) {
        return $newPromise(function($resolve, $reject) use ($conn) {
            \Amp\async(function() use ($resolve, $reject, $conn) {
                try {
                    $conn->close();
                    $resolve(null);
                } catch (\Throwable $e) {
                    $reject($e);
                }
            });
        });
    };
};
$exports['_closeConnectionImpl'] = $_closeConnectionImpl;

$_closeChannelImpl = function($newPromise, $ch = null) use (&$_closeChannelImpl) {
    if (\func_num_args() < 2) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_closeChannelImpl) {
            return $_closeChannelImpl(...\array_merge($__args, $more));
        };
    }
    return function() use ($newPromise, $ch) {
        return $newPromise(function($resolve, $reject) use ($ch) {
            \Amp\async(function() use ($resolve, $reject, $ch) {
                try {
                    $ch->close();
                    $resolve(null);
                } catch (\Throwable $e) {
                    $reject($e);
                }
            });
        });
    };
};
$exports['_closeChannelImpl'] = $_closeChannelImpl;

return $exports;
