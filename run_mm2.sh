#!/bin/bash

# Generate random strings
generate_password() {
tr -dc 'A-Za-z0-9@~_\-|:+.' </dev/urandom | head -c 24
}
generate_passphrase() {
head -c 48 /dev/urandom | base64
}

# Resolve USERPASS from file, env, or MM2.json
if [ -f userpass ]; then
source userpass
fi
if [ -z "$USERPASS" ] && [ -n "$userpass" ]; then
USERPASS="$userpass"
fi
if [ -z "$USERPASS" ] && [ -f MM2.json ]; then
USERPASS=$(jq -r '.rpc_password // empty' MM2.json)
fi

# Auto-generate MM2.json if missing (non-interactive)
if [ ! -f MM2.json ]; then
RPC_PASS="${USERPASS}"
if [ -z "$RPC_PASS" ]; then
RPC_PASS="$(generate_password)"
USERPASS="$RPC_PASS"
fi
SEED_PASSPHRASE="${PASSPHRASE}"
if [ -z "$SEED_PASSPHRASE" ]; then
SEED_PASSPHRASE="$(generate_passphrase)"
fi

TMP_CONF="$(mktemp)"
jq -n \
--arg gui "DRAGON_SEED" \
--arg rpc "$RPC_PASS" \
--arg pass "$SEED_PASSPHRASE" \
--arg userhome "/${HOME#\"/\"}" \
'{
  gui: $gui,
  netid: 8762,
  i_am_seed: true,
  rpc_password: $rpc,
  passphrase: $pass,
  userhome: $userhome,
  seednodes: [],
  disable_p2p: false
}' > "$TMP_CONF"

if [ -n "$DOMAIN" ] && [ -f "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" ] && [ -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
TMP2="$(mktemp)"
jq --arg d "$DOMAIN" \
'. + { wss_certs: { server_priv_key: ("/etc/letsencrypt/live/" + $d + "/privkey.pem"), certificate: ("/etc/letsencrypt/live/" + $d + "/fullchain.pem") } }' "$TMP_CONF" > "$TMP2" && mv "$TMP2" "$TMP_CONF"
fi

mv "$TMP_CONF" MM2.json
echo "userpass=\"$RPC_PASS\"" > userpass
fi

# Refresh seednodes from remote list before starting
SEEDS=$(curl -fsSL https://raw.githubusercontent.com/GLEECBTC/coins/master/seed-nodes.json | jq -c '[.[].host]')
if [ -n "$SEEDS" ] && [ "$SEEDS" != "null" ] && [ -f MM2.json ]; then
TMP="$(mktemp)"
jq --argjson seeds "$SEEDS" '.seednodes = $seeds' MM2.json > "$TMP" && mv "$TMP" MM2.json
fi

# Start mm2 and verify
stdbuf -oL ./mm2 > mm2.log &
sleep 3
if [ -n "$USERPASS" ]; then
curl --url "http://127.0.0.1:7783" --data "{\"method\":\"version\",\"userpass\":\"$USERPASS\"}"
else
echo "Warning: USERPASS not set; unable to query version."
fi