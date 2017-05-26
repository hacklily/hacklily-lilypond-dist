#!/bin/bash
PID=$(lsof -t -i tcp:1225)
echo $PID
if [ -n "$PID" ]; then
    echo nonzero \'$PID\'
    kill $PID
    sleep 2
    PID=$(lsof -t -i tcp:1225)
    echo Sent SIGTERM.
    if [ -n "$PID" ]; then
        kill -9 $PID
        echo "Didn't work. Sent SIGKILL."
    fi
fi
