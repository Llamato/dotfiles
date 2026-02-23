#!/bin/sh
while true; do
    CPU_IDLE=$(mpstat | tail -n 1 | rev | cut -f1 -d" " | rev | cut -f1 -d.)
    CPU_USAGE=$((100-$CPU_IDLE))
    echo $CPU_USAGE > /sys/devices/platform/980070d0.pwm/dutyRate3
    sleep 15
done