#!/bin/sh
sudo dbus-send --print-reply --system   --dest=org.bluez   /org/bluez/hci0/dev_50_D4_5C_95_A5_E9   org.bluez.Device1.ConnectProfile   string:0000110b-0000-1000-8000-00805f9b34fb
