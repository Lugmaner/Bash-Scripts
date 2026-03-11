#!/bin/bash

time_out=$1
shift

"$@" &
pid=$!

sleep "$time_out" &
timer=$!

while kill -0 "$pid" 2> /dev/null; do
    if ! kill -0 "$timer" 2> /dev/null; then
        kill -SIGTERM "$pid" 2> /dev/null
        sleep 1
        if kill -0 "$pid" 2> /dev/null; then
            kill -SIGKILL "$pid" 2> /dev/null
        fi
        echo "time out!"
        exit 1
    fi
    sleep 1
    if kill -0 "$pid" 2> /dev/null; then
        echo "Still running..."
    fi
done
echo "process finished"
kill -SIGKILL "$timer" 2> /dev/null
exit 0
