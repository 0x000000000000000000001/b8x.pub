<?php

namespace Amp {
    $queue = [];
    function async(callable $operation): void
    {
        $GLOBALS['queue'][] = $operation;
    }
    function flush(): void
    {
        while ($operation = array_shift($GLOBALS['queue'])) {
            $operation();
        }
    }
}

namespace Amp\Sql {
    abstract class SqlConnectionPool {}
    interface SqlConnection
    {
        public function isClosed(): bool;
        public function close(): void;
    }
}

namespace Amp\Postgres {
    class PostgresConfig
    {
        public function __construct(
            public $host,
            public $port,
            public $user,
            public $password,
            public $database,
        ) {}
    }
    class PostgresConnectionPool extends \Amp\Sql\SqlConnectionPool
    {
        public array $returned = [];
        public $connection;
        public bool $closed = false;
        public function __construct(public $config, public $maximum, public $idle)
        {
            $this->connection = new \ConnectionDouble();
        }
        protected function pop()
        {
            return $this->connection;
        }
        protected function push($connection): void
        {
            $this->returned[] = $connection;
        }
        public function close(): void
        {
            $this->closed = true;
        }
    }
    function connect($config)
    {
        $GLOBALS['connectionsCreated']++;
        return $GLOBALS['nextConnection'];
    }
}

namespace {
    final class ConnectionDouble implements \Amp\Sql\SqlConnection
    {
        public array $calls = [];
        public array $rows = [['value' => 42]];
        public int $count = 3;
        public bool $closed = false;
        public ?\Throwable $failure = null;
        public $onClose;

        public function execute($sql, $parameters)
        {
            $this->calls[] = [$sql, $parameters];
            if ($this->failure) {
                throw $this->failure;
            }
            return new class ($this->rows, $this->count) implements \IteratorAggregate {
                public function __construct(private array $rows, private int $count) {}
                public function getIterator(): \Traversable
                {
                    yield from $this->rows;
                }
                public function getRowCount(): int
                {
                    return $this->count;
                }
                public function fetchRow(): ?array
                {
                    return $this->rows[0] ?? null;
                }
            };
        }
        public function query($sql)
        {
            return $this->execute($sql, []);
        }
        public function isClosed(): bool
        {
            return $this->closed;
        }
        public function close(): void
        {
            $this->closed = true;
            if ($this->onClose) {
                ($this->onClose)();
            }
        }
        public function onClose($callback): void
        {
            $this->onClose = $callback;
        }
    }

    function loadFfi(string $path): array
    {
        $exports = [];
        return require __DIR__ . '/../../src/' . $path;
    }
    $checks = 0;
    function check(bool $condition, string $message): void
    {
        $GLOBALS['checks']++;
        if (!$condition) {
            throw new \RuntimeException($message);
        }
    }
    function start($operation): object
    {
        $result = (object) ['value' => null, 'error' => null, 'settled' => 0];
        $result->cancel = $operation(
            function ($error) use ($result) {
                $result->error = $error;
                $result->settled++;
            },
            function ($value) use ($result) {
                $result->value = $value;
                $result->settled++;
            },
        );
        return $result;
    }

    $pg = loadFfi('Infra/Client/Postgres/Postgres.php');
    $encoderCalls = [];
    $encodeJson = function ($value) use (&$encoderCalls) {
        $encoderCalls[] = $value;
        return json_encode($value, JSON_THROW_ON_ERROR);
    };
    $connection = new ConnectionDouble();
    $object = (object) ['name' => 'é'];
    $operation = $pg['_query']($encodeJson, $connection, 'SELECT $2, $1, $2', [
        $object,
        [true, null, ['quoted"', false]],
    ]);
    check($connection->calls === [], 'Constructing Aff must not run the query');
    $result = start($operation);
    check($connection->calls === [], 'Amp must schedule query execution');
    \Amp\flush();
    check($result->settled === 1 && $result->value === $connection->rows, 'Rows are returned once');
    check($encoderCalls === [$object], 'Objects are encoded through the injected codec');
    check(
        $connection->calls[0] === [
            'SELECT $1, $2, $1',
            ['{"true",NULL,{"quoted\\"","false"}}', '{"name":"\\u00e9"}'],
        ],
        'Parameters preserve PostgreSQL arrays and placeholder order',
    );

    $cancelled = 0;
    ($result->cancel)(
        new \RuntimeException('cancel'),
        function () {
            throw new \RuntimeException('Cancellation failed');
        },
        function () use (&$cancelled) {
            $cancelled++;
        },
    );
    check($cancelled === 1, 'Cancellation acknowledges once');
    $count = start($pg['_queryCount']($encodeJson, $connection, 'UPDATE rows SET value = 1', []));
    \Amp\flush();
    check($count->value === 3, 'Affected row count is returned');
    $connection->failure = new \RuntimeException('database failure');
    $failed = start($pg['_query']($encodeJson, $connection, 'SELECT 1', []));
    \Amp\flush();
    check(
        $failed->error === $connection->failure && $failed->settled === 1,
        'Database errors reach the error callback',
    );
    $connection->failure = null;

    $codecError = new \RuntimeException('codec failure');
    $brokenCodec = static function ($value) use ($codecError) {
        throw $codecError;
    };
    $failedCodec = start($pg['_query']($brokenCodec, $connection, 'SELECT $1', [$object]));
    \Amp\flush();
    check(
        $failedCodec->error === $codecError && $failedCodec->settled === 1,
        'Codec failures reach the error callback',
    );

    $callbackError = new \RuntimeException('callback failure');
    $errorCallbacks = 0;
    $pg['_query']($encodeJson, $connection, 'SELECT 1', [])(
        function ($error) use (&$errorCallbacks) {
            $errorCallbacks++;
        },
        function ($rows) use ($callbackError) {
            throw $callbackError;
        },
    );
    try {
        \Amp\flush();
        throw new \RuntimeException('The callback exception was swallowed');
    } catch (\Throwable $error) {
        check(
            $error === $callbackError && $errorCallbacks === 0,
            'A success callback exception is not reported as a database error',
        );
    }

    $poolEffect = $pg['_createConnectionPoolHandle'](
        'host name',
        5432,
        'db',
        'user',
        'quoted password',
        2500,
    );
    $pool = $poolEffect();
    check(
        $pool->config->password === 'quoted password' && $pool->idle === 2,
        'Pool configuration retains credentials and idle duration',
    );
    $dedicated = start($pg['_dedicate']($pool));
    \Amp\flush();
    $query = start($pg['_query']($encodeJson, $dedicated->value, 'SELECT 1', []));
    \Amp\flush();
    check(
        count($pool->connection->calls) === 1,
        'Dedicated handles route to their borrowed connection',
    );
    start($pg['_release']($dedicated->value));
    start($pg['_release']($dedicated->value));
    \Amp\flush();
    check($pool->returned === [$pool->connection], 'Release returns the connection exactly once');

    $disconnectedPool = $poolEffect();
    $disconnected = start($pg['_dedicate']($disconnectedPool));
    \Amp\flush();
    $disconnectedPool->connection->close();
    start($pg['_release']($disconnected->value));
    start($pg['_release']($disconnected->value));
    \Amp\flush();
    check(
        $disconnectedPool->returned === [$disconnectedPool->connection],
        'A closed borrowed connection is returned exactly once so the pool can reclaim its slot',
    );
    $closed = start($pg['_closeHandle']($pool));
    check(!$pool->closed, 'Close is deferred');
    \Amp\flush();
    check($pool->closed && $closed->settled === 1, 'Close completes');
    check(
        $pg['_escapeIdentifier']('some"table') === '"some""table"',
        'Identifier escaping is retained',
    );

    $projector = loadFfi('Infra/Projection/Projector.php');
    $connectionsCreated = 0;
    $nextConnection = new ConnectionDouble();
    $nextConnection->rows = [['locked' => true]];
    $lock = $projector['_tryAdvisoryLock']('localhost', 5432, 'db', 'user', 'secret', 'schema');
    check($connectionsCreated === 0, 'Lock acquisition is deferred');
    $locked = start($lock);
    $concurrent = start($lock);
    \Amp\flush();
    check(
        $locked->value === true && $concurrent->value === false,
        'Only one caller may hold a lock',
    );
    check($connectionsCreated === 1, 'Concurrent acquisition does not leak connections');
    check(
        $nextConnection->calls === [
            ['SELECT pg_try_advisory_lock(hashtext($1)) as locked', ['proj:schema']],
        ],
        'Lock query uses the dedicated session and a bound parameter',
    );
    if (($argv[1] ?? '') === '--lock-loss') {
        $nextConnection->close();
        exit(2);
    }
    $nextConnection = new ConnectionDouble();
    $nextConnection->rows = [['locked' => false]];
    $unavailable = start(
        $projector['_tryAdvisoryLock']('localhost', 5432, 'db', 'user', 'secret', 'busy'),
    );
    \Amp\flush();
    check(
        $unavailable->value === false && $nextConnection->closed,
        'Unavailable locks close their dedicated connection',
    );
    $nextConnection = new ConnectionDouble();
    $nextConnection->failure = new \RuntimeException('offline');
    $offline = start(
        $projector['_tryAdvisoryLock']('localhost', 5432, 'db', 'user', 'secret', 'offline'),
    );
    \Amp\flush();
    check(
        $offline->value === false && $nextConnection->closed,
        'Failed lock attempts close their connection and permit retry',
    );
    $process = proc_open(
        [PHP_BINARY, __FILE__, '--lock-loss'],
        [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']],
        $pipes,
    );
    fclose($pipes[0]);
    stream_get_contents($pipes[1]);
    fclose($pipes[1]);
    $errorOutput = stream_get_contents($pipes[2]);
    fclose($pipes[2]);
    check(
        proc_close($process) === 1 &&
            str_contains($errorOutput, 'Dedicated connection closed unexpectedly'),
        'Losing the lock session terminates the projector',
    );
    echo "$checks PostgreSQL and projector FFI checks passed\n";
}
