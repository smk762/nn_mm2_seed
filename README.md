# Basic scripts for running a MM2 Seed Node on your 2022 Testnet Node

Komodo Platform's [AtomicDEX-API](https://github.com/KomodoPlatform/atomicDEX-API) is an open-source atomic-swap protocol for trading seamlessly between essentially any blockchain asset in existence. Seed nodes play an essential part in orderbook propagation and relaying information about peers within the network and the status of swaps in progress. 

With the start of the 6th Komodo Notary Node Season, operators will be running a seed node on their third party (3P) server to further decentralize the network. This expands the current number of seed nodes from half a dozen to over 60 nodes, distributed geographically across the planet, and maintained by a diverse group of respected people within the Komodo community with great expertise in KMD related technologies and the ability to rapidly deploy updates and assist each other with troubleshooting as required.

Operators with the best metrics in terms of uptime and responsiveness to updates will also be rewarded with bonus points towards their Season 5 score, and the chance to win automatic re-election.

**For each hour of uptime with the correct version, Notary Nodes will receive 0.2 points to their testnet score (starting at epoch timestamp 1653091199)**

You'll need to open port 38890 - `sudo ufw allow 38890`
And port 15885 - `sudo ufw allow 15885`


The simple scripts in this repository will assist operators in setting up their seed node and keeping it up to date whenever update announcements are broadcast.

## gen_conf.py
Creates an **MM2.json** config file to define node as seed. For testnet, we will be using a different `netid`, so this wont be part of the main AtomicDEX-API network.

## update_coins.sh
Downloads latest **coins** file from https://github.com/KomodoPlatform/coins/

## update_mm2.sh
Downloads latest **mm2** binary from https://github.com/KomodoPlatform/atomicDEX-API/releases

## run_mm2.sh
Launches mm2, and logs output.

## stop_mm2.sh
Stops mm2.

# Setup

- Clone repository - `git clone https://github.com/smk762/nn_mm2_seed/ && cd nn_mm2_seed`
- Switch to 2022-testnet branch - `git checkout 2022-testnet`
- Install pip requirements - `pip3 install -r requirements.txt`
- Install `jq` - `sudo apt install jq`
- Get latest coins file - `./update_coins.sh`
- Get latest MM2 binary - `./update_mm2.sh`
- Generate config - `./gen_conf.py` (**Don't use your Notary passphrase!** Use a fresh one. This passphrase will be linked to your **PeerID** and should not be changed later)
- Start MM2 - `run_mm2.sh`
- Find your PeerID in mm2.log `cat mm2.log | grep  'Local peer id'`
- Get your pubkey - `./get_pubkey.sh`
- Send the IP address (or domain name) of your server and your PeerID to smk in Discord DM in the following format:
```json
        "Dragonhound": {
            "pubkey": "027a9c3a7302422fd8107c39cc83f4bbf4669a0f41522b7bdcef961e18bf94ab2b",
            "IP": "195.201.40.82",
            "PeerID": "12D3KooWPkg85NpwtDJCRwZZxevDwcz7NxjrMcHWLNLfzfrTZZZ1"
        }
```
- To tail the logs in console - `tail -f mm2.log`

https://user-images.githubusercontent.com/35845239/124757579-4efd2700-df60-11eb-9e44-2727141d220d.mp4

# Additional Resources
- Developer docs: https://developers.komodoplatform.com/basic-docs/atomicdex-api-legacy/rational_number_note.html
- Cipi's MM2 scripts: https://github.com/cipig/mmtools
- PytomicDEX: https://github.com/smk762/pytomicDEX_makerbot

