<?php

$_pg_format_param = function($val) use (&$_pg_format_param) {
    if (\is_object($val)) {
        return \json_encode($val, JSON_UNESCAPED_UNICODE);
    }
    if (\is_bool($val)) {
        return $val ? 'true' : 'false';
    }
    if (\is_array($val)) {
        $result = '{';
        $first = true;
        foreach ($val as $v) {
            if (!$first) $result .= ',';
            $first = false;
            if ($v === null) {
                $result .= 'NULL';
            } else if (\is_array($v)) {
                $result .= $_pg_format_param($v);
            } else {
                $str = \is_object($v) ? \json_encode($v, JSON_UNESCAPED_UNICODE) : (\is_bool($v) ? ($v ? 'true' : 'false') : (string)$v);
                $escaped = str_replace(['\\', '"'], ['\\\\', '\\"'], $str);
                $result .= '"' . $escaped . '"';
            }
        }
        $result .= '}';
        return $result;
    }
    if ($val === null) {
        return null;
    }
    return (string)$val;
};

$_normalize_params = function($params) use (&$_pg_format_param) {
    if (!\is_array($params)) return $params;
    return array_map($_pg_format_param, $params);
};

$_createConnectionPoolHandle = function($host, $port = null, $database = null, $user = null, $password = null, $idleTimeoutMs = null) use (&$_createConnectionPoolHandle) {
    if (\func_num_args() < 6) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_createConnectionPoolHandle) {
            return $_createConnectionPoolHandle(...\array_merge($__args, $more));
        };
    }
    return function() use ($host, $port, $database, $user, $password, $idleTimeoutMs) {
        $connStr = "host=$host port=$port dbname=$database user=$user password=$password";
        $config = \Amp\Postgres\PostgresConfig::fromString($connStr);
        $maxConnections = 100;
        $idleTimeoutSec = \max(1, (int)($idleTimeoutMs / 1000));
        return new \Amp\Postgres\PostgresConnectionPool($config, $maxConnections, $idleTimeoutSec);
    };
};

$_closeHandle = function($pool) {
    return function() use ($pool) {
        if (method_exists($pool, 'close')) {
            $pool->close();
        }
        return null;
    };
};

$pg_execute_async = function($executor, $query, $params, $isCount) use (&$_normalize_params) {
    $normalized_params = $_normalize_params($params) ?? [];

    if (\is_object($executor) && isset($executor->conn)) {
        $executor = $executor->conn;
    }

    // Fix amphp/postgres out-of-order numbered parameters bug
    if (!empty($normalized_params)) {
        $new_params = [];
        $next_idx = 1;
        $seen = [];
        
        $query = preg_replace_callback(
            "/(['\"])(?:\\\\(?:\\\\|\\1)|(?!\\1).)*+\\1(*SKIP)(*FAIL)|\\$([0-9]+)/msxS",
            function ($matches) use (&$new_params, &$next_idx, &$seen, $normalized_params) {
                if (!isset($matches[2])) return $matches[0];
                $old_idx = (int)$matches[2];
                if (!isset($seen[$old_idx])) {
                    $seen[$old_idx] = $next_idx++;
                    $new_params[$seen[$old_idx] - 1] = $normalized_params[$old_idx - 1] ?? null;
                }
                return '$' . $seen[$old_idx];
            },
            $query
        );
        $normalized_params = $new_params;
    }

    while (true) {
        try {
            if (empty($normalized_params)) {
                $result = $executor->query($query);
            } else {
                $result = $executor->execute($query, $normalized_params);
            }
            
            if ($isCount) {
                return $result->getRowCount() ?? 0;
            }

            $rows = [];
            foreach ($result as $row) {
                $rows[] = (object)$row;
            }
            return $rows;
        } catch (\Throwable $e) {
            if (strpos($e->getMessage(), 'DISCARD ALL') !== false) {
                // Ignore poisoned connection error and retry
                continue;
            }
            throw $e;
        }
    }
};

$_query = function($handle, $queryString = null, $params = null) use (&$_query, &$pg_execute_async) {
    if (\func_num_args() < 3) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_query, &$pg_execute_async) {
            return $_query(...\array_merge($__args, $more));
        };
    }
    return function() use ($handle, $queryString, $params, &$pg_execute_async) {
        if (!is_string($queryString)) {
            echo "\n\n=== INVALID QUERY STRING ===\n";
            var_dump($queryString);
            echo "============================\n\n";
        }
        return $pg_execute_async($handle, $queryString, $params, false);
    };
};

$_queryCount = function($handle, $queryString = null, $params = null) use (&$_queryCount, &$pg_execute_async) {
    if (\func_num_args() < 3) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_queryCount, &$pg_execute_async) {
            return $_queryCount(...\array_merge($__args, $more));
        };
    }
    return function() use ($handle, $queryString, $params, &$pg_execute_async) {
        return $pg_execute_async($handle, $queryString, $params, true);
    };
};

$_escapeIdentifier = function($identifier) {
    return '"' . str_replace('"', '""', $identifier) . '"';
};

$_dedicate = function($pool) {
    return function() use ($pool) {
        if ($pool instanceof \Amp\Sql\SqlConnectionPool) {
            $pop = \Closure::bind(function($p) {
                return $p->pop();
            }, null, \get_class($pool));
            
            $conn = $pop($pool);
            
            return new class($pool, $conn) {
                public $pool;
                public $conn;
                private $released = false;
                
                public function __construct($pool, $conn) {
                    $this->pool = $pool;
                    $this->conn = $conn;
                }
                
                public function release() {
                    if ($this->released) return;
                    $this->released = true;
                    if ($this->conn instanceof \Amp\Sql\SqlConnection && !$this->conn->isClosed()) {
                        $push = \Closure::bind(function($p, $c) {
                            $p->push($c);
                        }, null, \get_class($this->pool));
                        try {
                            $push($this->pool, $this->conn);
                        } catch (\Throwable $e) {}
                    }
                }
                
                public function __destruct() {
                    $this->release();
                }
            };
        }
        return $pool;
    };
};

$_release = function($handle) {
    return function() use ($handle) {
        if (\is_object($handle) && method_exists($handle, 'release')) {
            $handle->release();
        }
        return null;
    };
};

$exports['_createConnectionPoolHandle'] = $_createConnectionPoolHandle;
$exports['_closeHandle'] = $_closeHandle;
$exports['_query'] = $_query;
$exports['_queryCount'] = $_queryCount;
$exports['_escapeIdentifier'] = $_escapeIdentifier;
$exports['_dedicate'] = $_dedicate;
$exports['_release'] = $_release;

return $exports;
