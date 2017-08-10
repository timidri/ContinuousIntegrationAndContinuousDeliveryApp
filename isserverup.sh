#!/usr/bin/env bash
SERVER=$1
PORT=$2
timeout 2 bash -c "</dev/tcp/$SERVER/$PORT"; echo $?
