<?php

$_tryAdvisoryLock = function($host, $port = null, $database = null, $user = null, $password = null, $lockName = null) use (&$_tryAdvisoryLock) {
    if (\func_num_args() < 6) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_tryAdvisoryLock) {
            return $_tryAdvisoryLock(...\array_merge($__args, $more));
        };
    }
    
    return function() {
        $res = true;
        return new class($res) {
            private $val;
            public function __construct($val) { $this->val = $val; }
            public function then($k, $c = null) {
                $res = $k($this->val);
                if (\is_callable($res)) {
                    $res();
                }
                return $this;
            }
            public function catch($c) { return $this; }
            public function finally($f) { return $this; }
        };
    };
};

$exports['_tryAdvisoryLock'] = $_tryAdvisoryLock;

return $exports;
