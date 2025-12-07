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
echo "PASSPHRASE: $PASSPHRASE"
echo "SEED_PASSPHRASE: $SEED_PASSPHRASE"
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

mv "$TMP_CONF" MM2.json
echo "userpass=\"$RPC_PASS\"" > userpass
fi

# Ensure WSS cert paths are present/updated when certs exist
CERT_BASE=""
if [ -n "$DOMAIN" ]; then
if [ -f "/etc/letsencrypt/export/${DOMAIN}/privkey.pem" ] && [ -f "/etc/letsencrypt/export/${DOMAIN}/fullchain.pem" ]; then
CERT_BASE="/etc/letsencrypt/export/${DOMAIN}"
elif [ -f "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" ] && [ -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
CERT_BASE="/etc/letsencrypt/live/${DOMAIN}"
fi
fi
if [ -n "$CERT_BASE" ] && [ -f MM2.json ]; then
TMP_CERT="$(mktemp)"
jq --arg base "$CERT_BASE" \
'.wss_certs = { server_priv_key: ($base + "/privkey.pem"), certificate: ($base + "/fullchain.pem") }' \
MM2.json > "$TMP_CERT" && mv "$TMP_CERT" MM2.json
fi

# Ensure USERPASS matches MM2.json rpc_password and sync userpass file
if [ -f MM2.json ]; then
RPC_FROM_JSON="$(jq -r '.rpc_password // empty' MM2.json)"
if [ -n "$RPC_FROM_JSON" ]; then
USERPASS="$RPC_FROM_JSON"
echo "userpass=\"$USERPASS\"" > userpass
fi
fi
echo "Userpass: $USERPASS"


echo "Updating seednodes..."
# Refresh seednodes from remote list before starting
SEEDS=$(curl -fsSL https://raw.githubusercontent.com/GLEECBTC/coins/master/seed-nodes.json | jq -c '[.[].host]')
if [ -n "$SEEDS" ] && [ "$SEEDS" != "null" ] && [ -f MM2.json ]; then
TMP="$(mktemp)"
jq --argjson seeds "$SEEDS" '.seednodes = $seeds' MM2.json > "$TMP" && mv "$TMP" MM2.json
fi
echo "Seednodes: $SEEDS"

cat MM2.json

echo "Updating coins file..."
# Update coins file on each start into ~/.kdf/coins
mkdir -p "$HOME/.kdf"
if COINS_TMP=$(mktemp) && curl -fsSL https://raw.githubusercontent.com/GLEECBTC/coins/refs/heads/master/coins -o "$COINS_TMP"; then
mv "$COINS_TMP" "$HOME/.kdf/coins"
else
echo "Warning: failed to fetch coins file; continuing with existing file (if any)."
fi




# Start mm2 and verify
which kdf
echo "Starting kdf..."
echo "" > ~/kdf.log
stdbuf -oL kdf > ~/kdf.log &

sleep 3
if [ -n "$USERPASS" ]; then
curl --url "http://127.0.0.1:7783" --data "{\"method\":\"version\",\"userpass\":\"$USERPASS\"}"
else
echo "Warning: USERPASS not set; unable to query version."
fi

ls -al ~/kdf.log
tail -f ~/kdf.log
