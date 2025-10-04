#!/bin/sh

# Miyabi cant hibernate for some reason
if [ "$(hostname)" = "miyabi" ]; then
    echo Miyabi cant hibernate
    exit 1
elif [ "$(hostname)" = "wannabeonyx" ]; then
    echo The wanna be onyx can not hibernate either
else
    systemctl suspend
fi
