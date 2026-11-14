<?php

$lockConnections = [];

$exports['_tryAdvisoryLock'] = static function (
    $host,
    $port,
    $database,
    $user,
    $password,
    $lockName,
) use (&$lockConnections) {
    return static function ($onError, $onSuccess) use (
        $host,
        $port,
        $database,
        $user,
        $password,
        $lockName,
        &$lockConnections,
    ) {
        $key = \json_encode([$host, $port, $database, $user, $lockName], JSON_THROW_ON_ERROR);
        if (isset($lockConnections[$key])) {
            $onSuccess(false);
        } else {
            // Reserve the name while connecting so concurrent callers cannot both win.
            $lockConnections[$key] = true;
            \Amp\async(static function () use (
                $host,
                $port,
                $database,
                $user,
                $password,
                $lockName,
                $key,
                &$lockConnections,
                $onSuccess,
            ) {
                $connection = null;
                try {
                    $config = new \Amp\Postgres\PostgresConfig(
                        $host,
                        $port,
                        $user,
                        $password,
                        $database,
                    );
                    $connection = \Amp\Postgres\connect($config);
                    $result = $connection->execute(
                        'SELECT pg_try_advisory_lock(hashtext($1)) as locked',
                        ['proj:' . $lockName],
                    );
                    $locked = ($result->fetchRow()['locked'] ?? false) === true;
                } catch (\Throwable $error) {
                    $locked = false;
                }

                if ($locked) {
                    // Losing this session releases the lock: stop projecting immediately.
                    $connection->onClose(static function () {
                        \fwrite(
                            STDERR,
                            "[ProjectorLock] Dedicated connection closed unexpectedly.\n",
                        );
                        exit(1);
                    });
                    $lockConnections[$key] = $connection;
                } else {
                    unset($lockConnections[$key]);
                    $connection?->close();
                }
                $onSuccess($locked);
            });
        }
        // Cancellation does not release a held lock.
        return static function ($reason, $onCancelError, $onCancelSuccess) {
            $onCancelSuccess(null);
        };
    };
};

return $exports;
