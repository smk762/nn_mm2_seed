source userpass
curl --url "http://127.0.0.1:7783" --data "{\"method\":\"version\",\"userpass\":\"$userpass\"}"
echo ""
