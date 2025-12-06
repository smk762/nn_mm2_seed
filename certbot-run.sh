#!/bin/sh
set -eu

if [ -z "${DOMAIN:-}" ] || [ -z "${LETSENCRYPT_EMAIL:-}" ]; then
  echo "DOMAIN and LETSENCRYPT_EMAIL must be set in environment."
  exit 1
fi

# Obtain/renew certificate using standalone HTTP challenge on port 80
certbot certonly --standalone --non-interactive --agree-tos \
  -m "${LETSENCRYPT_EMAIL}" -d "${DOMAIN}" --keep-until-expiring \
  --preferred-challenges http || true

while :; do
  certbot renew --standalone --no-random-sleep-on-renew
  sleep 12h
done


