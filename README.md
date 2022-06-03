# Basic scripts for running a MM2 Seed Node on your Notary Node

Komodo Platform's [AtomicDEX-API](https://github.com/KomodoPlatform/atomicDEX-API) is an open-source atomic-swap protocol for trading seamlessly between essentially any blockchain asset in existence. Seed nodes play an essential part in orderbook propagation and relaying information about peers within the network and the status of swaps in progress. 

With the start of the 5th Komodo Notary Node Season, operators will be running a seed node on their third party (3P) server to further decentralize the network. This expands the current number of seed nodes from half a dozen to over 60 nodes, distributed geographically across the planet, and maintained by a diverse group of respected people within the Komodo community with great expertise in KMD related technologies and the ability to rapidly deploy updates and assist each other with troubleshooting as required.

Operators with the best metrics in terms of uptime and responsiveness to updates will also be rewarded with bonus points towards their Season 5 score, and the chance to win automatic re-election.

**For each hour of uptime with the correct version, Notary Nodes will receive 0.2 points to their season score.**

You'll need to open port 38890 - `sudo ufw allow 38890`



The simple scripts in this repository will assist operators in setting up their seed node and keeping it up to date whenever update announcements are broadcast.

## gen_conf.py
Creates an **MM2.json** config file to define node as seed.

## update_coins.sh
Downloads latest **coins** file from https://github.com/KomodoPlatform/coins/

## update_mm2.sh
Downloads latest **mm2** binary from https://github.com/KomodoPlatform/atomicDEX-API/releases

## run_mm2.sh
Launches mm2, and logs output.

## stop_mm2.sh
Stops mm2.

# Setup

- Clone repository `git clone https://github.com/smk762/nn_mm2_seed/ && cd nn_mm2_seed`
- Install pip requirements - `pip3 install -r requirements.txt`
- Get latest coins file - `./update_coins.sh`
- Get latest MM2 binary - `./update_mm2.sh`
- Generate config - `./gen_conf.py` (**Don't use your Notary passphrase!** Use a fresh one. This passphrase will be linked to your **PeerID** and should not be changed later)
- Start MM2 - `run_mm2.sh`
- Find your PeerID in mm2.log `cat mm2.log | grep  'Local peer id'`
- Send the IP address (or domain name) of your server and your PeerID to smk in Discord DM (can be run on Third Party nodes, or a separate VPS in any region)


https://user-images.githubusercontent.com/35845239/124757579-4efd2700-df60-11eb-9e44-2727141d220d.mp4


# WSS Setup
This process depend on which webserver you have in use. For further reading, check out: https://medium.com/@hack4mer/how-to-setup-wss-for-ratchet-websocket-server-on-nginx-or-apache-c5061229860a

### Step 1: Obtain a Domain Name
There are many providers, and they are available for as low as $5/year. I'll use https://www.hover.com/domain-pricing for example.

Setup nameservers for DNS propagation - https://help.hover.com/hc/en-us/articles/217282477

Setup DNS records to link IP address with domain - https://help.hover.com/hc/en-us/articles/217282457-Managing-DNS-records-

I'll be using my 3P nodes, though you can run the mm2 seednode on a different server in any region.

My domain name will be `smk.dog`. The settings below will create the subdomains `dev.smk.dog` and `na.smk.dog` pointing to my 3P Dev & NA servers.

![image](https://user-images.githubusercontent.com/35845239/171760406-3dfb473a-5db9-47eb-bdaf-3b4e81ae739c.png)

Additional subdomains for each of your nodes can be added as required.

![image](https://user-images.githubusercontent.com/35845239/171760521-1f0c3a59-3fbd-4c9e-8abf-6249bd856c57.png)

DNS propagation can take a little while. You can check the progress at https://www.whatsmydns.net and / or via ping in terminal.

`ping dev.smk.dog`

### Step 2: Generate SSL certificates with [LetsEncrypt](https://letsencrypt.org/getting-started/)

The simplest way to do this is with the [EFF's Certbot](https://certbot.eff.org/)

```bash
sudo apt update && sudo apt upgrade
sudo apt install snapd
sudo snap install core; sudo snap refresh core
sudo apt remove certbot  # Remove older version if existing
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo apt install nginx
# Temporarily open port 80 so certbot can confirm certificate config
sudo ufw allow 80
sudo certbot certonly --nginx  # This might fail is DNS propagation is not yet complete - if so, try again later
```
![image](https://user-images.githubusercontent.com/35845239/171763816-a755bdb5-19ed-48ea-8c48-c8b69c540c0c.png)


Once the certs are generated, add entries to your MM2.json as below, substituting in your subdomain as required:

```json
"wss_certs": {
    "server_priv_key":"/etc/letsencrypt/live/dev.smk.dog/privkey.pem",
    "certificate":"/etc/letsencrypt/live/dev.smk.dog/fullchain.pem"
}
```

### Step 3: Open the mm2 Seednode WSS Port, and Close Port 80

```bash
sudo ufw allow 38900
sudo ufw status numbered    # To find the ID numbers for port 80
sudo ufw delete 20          # Remove port 80 on ipv6
sudo ufw delete 10          # Remove port 80 on ipv4
```

### Step 4: Restart MM2

Start mm2 and review your logs.
```bash
./run_mm2.sh && tail -f mm2.log
```

If you see an error like `'Error reading WSS key/cert file "/etc/letsencrypt/live/dev.smk.dog/privkey.pem": Permission denied (os error 13)'` you need to change the ownership of these files for mm2 to be able to access them.

```bash
sudo chown smk762:smk762 /etc/letsencrypt/archive/dev.smk.dog/privkey1.pem
sudo chown smk762:smk762 /etc/letsencrypt/archive/dev.smk.dog/fullchain1.pem
```

Once it looks like it is working, you can confirm external connections are being accepted via https://websocketking.com/

![image](https://user-images.githubusercontent.com/35845239/171772951-86d6fb8e-c9d0-40ee-88b6-3124a942d1b8.png)

