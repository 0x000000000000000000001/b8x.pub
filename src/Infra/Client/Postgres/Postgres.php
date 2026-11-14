<?php

$runAsync = static function (callable $operation) {
    return static function (callable $onError, callable $onSuccess) use ($operation) {
        \Amp\async(static function () use ($operation, $onError, $onSuccess) {
            try {
                $result = $operation();
            } catch (\Throwable $error) {
                $onError($error);
                return;
            }
            $onSuccess($result);
        });
        // The database operation continues when its Aff caller is cancelled.
        return static function ($reason, $onCancelError, $onCancelSuccess) {
            $onCancelSuccess(null);
        };
    };
};

$formatParameter = static function ($value, callable $encodeJson) use (&$formatParameter) {
    if (\is_object($value)) {
        return $encodeJson($value);
    }
    if (\is_bool($value)) {
        return $value ? 'true' : 'false';
    }
    if (\is_array($value)) {
        $elements = [];
        foreach ($value as $element) {
            if ($element === null) {
                $elements[] = 'NULL';
            } elseif (\is_array($element)) {
                $elements[] = $formatParameter($element, $encodeJson);
            } else {
                $text = $formatParameter($element, $encodeJson);
                $elements[] = '"' . \str_replace(['\\', '"'], ['\\\\', '\\"'], $text) . '"';
            }
        }
        return '{' . \implode(',', $elements) . '}';
    }
    return $value === null ? null : (string) $value;
};

$prepareQuery = static function ($query, $parameters) {
    if ($parameters === []) {
        return [$query, $parameters];
    }
    // Amp numbers parameters in their first occurrence order.
    $orderedParameters = [];
    $positions = [];
    $query = \preg_replace_callback(
        "/(['\"])(?:\\\\(?:\\\\|\\1)|(?!\\1).)*+\\1(*SKIP)(*FAIL)|\\$([0-9]+)/msxS",
        static function ($matches) use (&$orderedParameters, &$positions, $parameters) {
            if (!isset($matches[2])) {
                return $matches[0];
            }
            $originalPosition = (int) $matches[2];
            if (!isset($positions[$originalPosition])) {
                $orderedParameters[] = $parameters[$originalPosition - 1] ?? null;
                $positions[$originalPosition] = \count($orderedParameters);
            }
            return '$' . $positions[$originalPosition];
        },
        $query,
    );
    return [$query, $orderedParameters];
};

$executeQuery = static function ($handle, $query, $parameters, $countOnly, $encodeJson) use (
    $formatParameter,
    $prepareQuery,
) {
    $parameters = \array_map(
        static fn($value) => $formatParameter($value, $encodeJson),
        $parameters,
    );
    [$query, $parameters] = $prepareQuery($query, $parameters);
    $executor = \is_object($handle) && isset($handle->connection) ? $handle->connection : $handle;

    while (true) {
        try {
            $result =
                $parameters === []
                    ? $executor->query($query)
                    : $executor->execute($query, $parameters);
            if ($countOnly) {
                return $result->getRowCount() ?? 0;
            }
            return \iterator_to_array($result, false);
        } catch (\Throwable $error) {
            // Preserve the pool's recovery from a poisoned, discarded connection.
            if (\str_contains($error->getMessage(), 'DISCARD ALL')) {
                continue;
            }
            throw $error;
        }
    }
};

$exports['_createConnectionPoolHandle'] = static function (
    $host,
    $port,
    $database,
    $user,
    $password,
    $idleTimeoutMs,
) {
    return static function () use ($host, $port, $database, $user, $password, $idleTimeoutMs) {
        $config = new \Amp\Postgres\PostgresConfig($host, $port, $user, $password, $database);
        $maxConnections = 100;
        $idleTimeoutSeconds = \max(1, (int) ($idleTimeoutMs / 1000));
        return new \Amp\Postgres\PostgresConnectionPool(
            $config,
            $maxConnections,
            $idleTimeoutSeconds,
        );
    };
};

$exports['_closeHandle'] = static function ($handle) use ($runAsync) {
    return $runAsync(static function () use ($handle) {
        if (\method_exists($handle, 'close')) {
            $handle->close();
        }
        return null;
    });
};

$exports['_query'] = static function ($encodeJson, $handle, $query, $parameters) use (
    $runAsync,
    $executeQuery,
) {
    return $runAsync(
        static fn() => $executeQuery($handle, $query, $parameters, false, $encodeJson),
    );
};

$exports['_queryCount'] = static function ($encodeJson, $handle, $query, $parameters) use (
    $runAsync,
    $executeQuery,
) {
    return $runAsync(static fn() => $executeQuery($handle, $query, $parameters, true, $encodeJson));
};

$exports['_escapeIdentifier'] = static fn($identifier) => '"' .
    \str_replace('"', '""', $identifier) .
    '"';

$exports['_dedicate'] = static function ($pool) use ($runAsync) {
    return $runAsync(static function () use ($pool) {
        if (!($pool instanceof \Amp\Sql\SqlConnectionPool)) {
            return $pool;
        }
        // Amp exposes borrowing only through its protected pool operations.
        $borrow = \Closure::bind(static fn($pool) => $pool->pop(), null, \get_class($pool));
        return new class ($pool, $borrow($pool)) {
            private bool $released = false;

            public function __construct(private $pool, public $connection) {}

            public function release(): void
            {
                if ($this->released) {
                    return;
                }
                $this->released = true;
                if (!($this->connection instanceof \Amp\Sql\SqlConnection)) {
                    return;
                }
                // Return closed connections too: Amp reclaims them when borrowing again.
                $returnConnection = \Closure::bind(
                    static fn($pool, $connection) => $pool->push($connection),
                    null,
                    \get_class($this->pool),
                );
                try {
                    $returnConnection($this->pool, $this->connection);
                } catch (\Throwable $error) {
                    // A pool that has closed cannot accept the borrowed connection.
                    $this->connection->close();
                }
            }

            public function __destruct()
            {
                $this->release();
            }
        };
    });
};

$exports['_release'] = static function ($handle) use ($runAsync) {
    return $runAsync(static function () use ($handle) {
        if (\is_object($handle) && \method_exists($handle, 'release')) {
            $handle->release();
        }
        return null;
    });
};

return $exports;
