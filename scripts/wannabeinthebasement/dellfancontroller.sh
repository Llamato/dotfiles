#!/bin/sh
LOWTEMP=50
MIDTEMP=60
HIGHTEMP=80

LOWSPEED=0x06
MIDSPEED=0x20
HIGHSPEED=0x64

${ipmitool}/bin/ipmitool raw 0x30 0x30 0x01 0x00
while true; do
    HIGHESTTEMP=$(${ipmitool}/bin/ipmitool sdr type temperature | ${pkgs.gnugrep}/bin/grep -Po '\d+(?= degrees C)' | sort -n | tail -1)
    if [ -z "$HIGHESTTEMP" ]; then
        echo "No temperature data found"
        sleep 15
        continue
    fi
    
    if [ $HIGHESTTEMP -ge $HIGHTEMP ]; then
        ${ipmitool}/bin/ipmitool raw 0x30 0x30 0x02 0xff $HIGHSPEED
    elif [ $HIGHESTTEMP -ge $MIDTEMP ]; then
        ${ipmitool}/bin/ipmitool raw 0x30 0x30 0x02 0xff $MIDSPEED
    elif [ $HIGHESTTEMP -le $LOWTEMP ]; then
        ${ipmitool}/bin/ipmitool raw 0x30 0x30 0x02 0xff $LOWSPEED
    fi
    
    sleep 15
done