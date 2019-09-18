#!/bin/sh

HOST=$1
sleep 5
# use 'time' to take time of the curl request
/usr/bin/time -f "%e" curl $HOST:8080 --data-binary @/home/img.png