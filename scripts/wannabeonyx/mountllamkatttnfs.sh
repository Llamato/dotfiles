#!/bin/sh
mkdir -p ~/umounts/llamkatttnfs
sudo mount -t nfs -o nolock 10.20.30.4:/mnt ~/umounts/llamkatttnfs/
