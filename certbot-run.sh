#!/bin/sh
set -eu

if [ -z "${DOMAIN:-}" ] || [ -z "${LETSENCRYPT_EMAIL:-}" ]; then
  echo "DOMAIN and LETSENCRYPT_EMAIL must be set in environment."
  exit 1
fi

# Obtain/renew certificate using standalone HTTP challenge on port 80
echo "Certbot: requesting/validating certificate for ${DOMAIN}"
certbot certonly --standalone --non-interactive --agree-tos \
  -m "${LETSENCRYPT_EMAIL}" -d "${DOMAIN}" --keep-until-expiring \
  --preferred-challenges http || true
echo "Certbot: initial obtain attempt finished (errors above can be transient if DNS/port 80 not yet ready)"

while :; do
  echo "Certbot: running renewal check..."
  certbot renew --standalone --no-random-sleep-on-renew || true
  sleep 12h
done


