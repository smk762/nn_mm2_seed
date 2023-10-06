#!/usr/bin/env python3
import json
import string
import random
import os.path
import mnemonic

conf = {
    "gui": "NN_SEED",
    "netid": 8762,
    "i_am_seed":True,
    "rpc_password": "RPC_CONTROL_USERPASSWORD",
    "passphrase": "YOUR SEED PHRASE",
    "userhome": "/${HOME#\"/\"}"
}

special_chars = ["@", "~", "-", "_", "|", ":", "+"]

def generate_rpc_pass(length):
	rpc_pass = ""
	quart = int(length/4)
	while len(rpc_pass) < length:
		rpc_pass += ''.join(random.sample(string.ascii_lowercase, random.randint(1,quart)))
		rpc_pass += ''.join(random.sample(string.ascii_uppercase, random.randint(1,quart)))
		rpc_pass += ''.join(random.sample(string.digits, random.randint(1,quart)))
		rpc_pass += ''.join(random.sample(special_chars, random.randint(1,quart)))
	str_list = list(rpc_pass)
	random.shuffle(str_list)
	return ''.join(str_list)
	 
resp = "Y"
if os.path.exists("MM2.json"):
	resp = input("You already have an MM2.json file! Generate a new one? [Y/N]: ")
	while resp not in ["Y", "y", "N", "n"]:
		print("Invalid input!")
		resp = input("You already have an MM2.json file! Generate a new one? [Y/N]: ")

if resp in ["Y", "y"]:
	rpc_password = generate_rpc_pass(16)
	conf.update({"rpc_password": rpc_password})

	new_seed = input("[E]nter seed manually or [G]enerate one? [E/G]: ")
	while new_seed not in ["G", "g", "E", "e"]:
		print("Invalid input!")
		new_seed = input("[E]nter seed manually or [G]enerate one? [E/G]: ")

	if new_seed in ["E", "e"]:
		passphrase = input("Enter a seed phrase: ")
	else:		
		m = mnemonic.Mnemonic('english')
		passphrase = m.generate(strength=256)

	conf.update({"passphrase": passphrase})

	with open("MM2.json", "w+") as f:
		json.dump(conf, f, indent=4)

	print("MM2.json file created.")

	with open("userpass", "w+") as f:
		f.write(f'userpass="{rpc_password}"')
	print("userpass file created.")
