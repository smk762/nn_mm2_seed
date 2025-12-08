## Turnkey dockerised setup for running a KDF Seed Node

The included `docker-compose.yml` provides a turnkey setup. It provisions/renews LetsEncrypt certs and runs the mm2 seednode. On every start, `run_mm2.sh` refreshes `coins` file and the `seednodes` field in `MM2.json` from `https://raw.githubusercontent.com/GLEECBTC/coins/master/seed-nodes.json` to keep peers current.

### Step 1 Install Docker and Docker Compose plugin  
### Step 2 Create a `.env` file in the repo root with your settings:

```bash
DOMAIN=your.subdomain.tld
LETSENCRYPT_EMAIL=you@example.com
# Optional: CloudFlare API token for DNS-01 challenge (no port 80 needed)
# Get your token from: https://dash.cloudflare.com/profile/api-tokens
# Create a token with "Edit zone DNS" permissions for your domain
# CLOUDFLARE_API_TOKEN=your_cloudflare_api_token_here
# Optional: predefine RPC password (else generated/loaded)
USERPASS=RPC_UserP@SSW0RD
# Optional: predefine your mm2 passphrase (else generated)
# PASSPHRASE=correct horse battery staple
```

### Step 3 From the repo root, start:

```bash
docker compose up -d --build && docker compose logs -f --tail 5
```


### Step 4: Open the KDF Seednode Ports

```bash
sudo ufw allow 42855
sudo ufw allow 42845
```

**Note about port 80:** If you're using CloudFlare DNS plugin (by setting `CLOUDFLARE_API_TOKEN`), port 80 is not needed and can remain closed. Otherwise, port 80 must be open for Let's Encrypt HTTP validation.

Notes:
- Certificates are created by the `certbot` service and mounted read-only to the `kdf` service.
- **CloudFlare DNS Plugin:** If `CLOUDFLARE_API_TOKEN` is set in `.env`, certbot will use CloudFlare DNS-01 challenge instead of HTTP validation. This means port 80 doesn't need to be open. The token should have "Edit zone DNS" permissions for your domain. Get your token from [CloudFlare API Tokens](https://dash.cloudflare.com/profile/api-tokens).
- **Standalone Mode (default):** If `CLOUDFLARE_API_TOKEN` is not set, certbot uses standalone HTTP challenge on port 80. Ensure TCP/80 is reachable from the internet for issuance and renewals.
- `run_mm2.sh` auto-updates `MM2.json` `seednodes` from the remote list on each start.
- First boot is non-interactive: if `MM2.json` does not exist, it is generated automatically using `USERPASS` and `PASSPHRASE` envs (or securely generated defaults). If `DOMAIN` is set and certificates exist, `wss_certs` is added automatically.
- Certbot runs continuously inside its container and will attempt automatic renewals every ~12 hours.
- The `coins` file is refreshed automatically on each start from `https://raw.githubusercontent.com/GLEECBTC/coins/refs/heads/master/coins` and saved to `~/.kdf/coins` inside the container.
