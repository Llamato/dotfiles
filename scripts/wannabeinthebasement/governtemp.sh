#!/bin/sh
LOWTEMP=50
MIDTEMP=60
HIGHTEMP=80

LOWSPEED=0x06
MIDSPEED=0x20
HIGHSPEED=0x64

while true; do
    HIGHESTTEMP=$(sudo ipmitool sdr type temperature | grep -Po '\d+(?= degrees C)' | sort -n | tail -1)
        if [ $HIGHESTTEMP -ge $HIGHTEMP ]; then
            ipmitool raw 0x30 0x30 0x02 0xff $HIGHSPEED
        elif [ $HIGHESTTEMP -ge $MIDTEMP ]; then
            ipmitool raw 0x30 0x30 0x02 0xff $MIDSPEED
        elif [ $HIGHESTTEMP -le $LOWTEMP ]; then
            ipmitool raw 0x30 0x30 0x02 0xff $LOWSPEED
        fi
    sleep 15s
done