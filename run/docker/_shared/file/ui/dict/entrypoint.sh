#!/bin/bash

(chown -R $(whoami):$(whoami) /db &>/dev/null) || true
(chmod -R 0770 /db &>/dev/null) || true

echo "Now running command: ./docker-entry.sh $@..."

(chown $(whoami):$(whoami) ./docker-entry.sh &>/dev/null) || true
(chmod +x ./docker-entry.sh &>/dev/null) || true
(chmod 0770 ./docker-entry.sh &>/dev/null) || true

exec "bash ./docker-entry.sh $@" # See https://hub.docker.com/layers/redislabs/redisinsight/latest/images/sha256-a0d1595dc6b4be3f46cf37ed7bdda36e2d141b1b27ac3fb7a0a607da07db6f4e?context=explore