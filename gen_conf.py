#!/usr/bin/env python3
import json
import random
import os.path

conf = {
    "gui": "NN_SEED",
    "netid": 7777,
    "i_am_seed":True,
    "rpc_password": "RPC_CONTROL_USERPASSWORD",
    "passphrase": "YOUR SEED PHRASE",
    "userhome": "/${HOME#\"/\"}"
}

if os.path.exists("MM2.json"):
	print("You already have an MM2.json file, move or delete it first.")
else:
	rpc_password = '%036x' % random.randrange(16**36)
	conf.update({"rpc_password": rpc_password})
	passphrase = input("Enter a seed phrase for your seed node: ")
	conf.update({"passphrase": passphrase})
	with open("MM2.json", "w+") as f:
		json.dump(conf, f, indent=4)
	print("MM2.json file created.")
