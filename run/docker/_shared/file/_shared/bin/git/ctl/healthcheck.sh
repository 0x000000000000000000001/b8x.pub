#!/bin/bash
#
# This will fail if the loops of run.sh are broken and stopped for some reason (i.e. 5m of inactivity)
#
# Required envs:
#   - $SOURCE (e.g. docs/public, app...)
#   - $MAX_PULL_DURATION
#

if [[ "$PAUSE" == "1" ]]; then
    exit 0
fi

target_dir=b8x
if [[ "$SOURCE" != "" ]]; then
    target_dir=b8x/$SOURCE
fi

trace_file=/var/www/$target_dir/var/.last_pull

if [ -f $trace_file ]; then
    . <(cat $trace_file 2>/dev/null | sed -e 's/^/export /g') &>/dev/null

    if [ "$LAST_PULL_ENDED_AT_TS" != '' ]; then
        now="$(date +%s)"

        diff=$(( now - LAST_PULL_ENDED_AT_TS ))

        if [ $diff -gt $(( 15 + MAX_PULL_DURATION )) ]; then
            exit 1
        fi
    fi
else
    exit 1
fi

exit 0
