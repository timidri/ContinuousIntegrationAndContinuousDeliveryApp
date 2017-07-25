#!/usr/bin/env bash
SERVER=centos-7-3.pdx.puppet.vm
PORT=8090
state=`nmap -p $PORT $SERVER | grep "$PORT" | grep open`
if [ -z "$state" ]; then
  echo "Connection to $SERVER on port $PORT has failed"
  exit 1
else
  echo "Connection to $SERVER on port $PORT was successful"
fi
