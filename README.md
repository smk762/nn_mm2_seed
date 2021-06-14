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
