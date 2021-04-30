#!/bin/bash
source userpass
stdbuf -oL ./mm2 > mm2.log &
sleep 3
curl --url "http://127.0.0.1:7783" --data "{\"method\":\"version\",\"userpass\":\"$userpass\"}"