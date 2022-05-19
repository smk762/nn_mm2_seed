#!/bin/bash
source userpass

curl --url "http://127.0.0.1:7783" --data "
{
     \"userpass\": \"${userpass}\",
     \"mmrpc\": \"2.0\",
     \"method\": \"get_public_key\",
     \"params\": {},
     \"id\": 0
}
"
echo
