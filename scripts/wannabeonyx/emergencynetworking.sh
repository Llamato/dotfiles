#!/bin/sh
sudo ip addr add 192.168.3.25/24 dev enp106s0u1
sudo ip route add default via 192.168.3.1
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
