<?php

$beforeOutput = explode('/output/', __DIR__)[0];

$rootDir = preg_replace('#/run/bak/(js|php)$#', '', $beforeOutput);

$exports['_rootDirAbsolutePath'] = $rootDir . '/';

return $exports;
