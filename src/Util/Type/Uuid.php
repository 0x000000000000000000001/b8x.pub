<?php

$exports['_generateV7Uuid'] = function() {
    return \Symfony\Component\Uid\Uuid::v7()->toRfc4122();
};

return $exports;
