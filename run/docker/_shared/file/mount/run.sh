#!/bin/sh

while true; do

    dir=/var/www/b8x

    mkdir -p $dir/var/gateway &>/dev/null
    echo "(re)Made $dir/var/gateway if nil..."

    mkdir -p $dir/var/api/cache &>/dev/null
    echo "(re)Made $dir/var/api/cache if nil..."

    mkdir -p $dir/var/news/tmp &>/dev/null
    chmod 1777 $dir/var/news/tmp &>/dev/null
    echo "(re)Made $dir/var/news/tmp if nil..."

    mkdir -p $dir/var/sock &>/dev/null
    echo "(re)Made $dir/var/sock if nil..."

    mkdir -p $dir/run/docker/$ENV/volume/pilot/data &>/dev/null
    echo "(re)Made $dir/run/docker/$ENV/volume/pilot/data if nil..."

    mkdir -p $dir/run/docker/$ENV/volume/db/data &>/dev/null
    echo "(re)Made $dir/run/docker/$ENV/volume/db/data if nil..."

    mkdir -p $dir/run/docker/$ENV/volume/db2/data &>/dev/null
    echo "(re)Made $dir/run/docker/$ENV/volume/db2/data if nil..."

    mkdir -p $dir/run/docker/$ENV/volume/mq/mnesia &>/dev/null
    echo "(re)Made $dir/run/docker/$ENV/volume/mq/mnesia if nil..."

    echo 'Sleeping a little while before next loop...'

    sleep 3

done
