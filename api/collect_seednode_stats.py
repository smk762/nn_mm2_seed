#!/usr/bin/env python3
import os
import csv
import sys
import json
import requests
import sqlite3
from dotenv import load_dotenv

# ENV VARS
load_dotenv()
MM2_USERPASS = os.getenv("MM2_USERPASS")
MM2_IP = "http://127.0.0.1:7783"
DB_PATH = os.getenv("DB_PATH")

conn = sqlite3.connect(DB_PATH)
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

def mm2_proxy(method, params=None):
	if not params:
		params = {}
	params.update({
		"method": method,
		"userpass": MM2_USERPASS,
		})
	r = requests.post(MM2_IP, json.dumps(params))
	print(r.json())
	return r

def get_seedinfo_from_csv():
	notary_seeds = []
	with open('notary_seednodes.csv', 'r') as file:
	    csv_file = csv.DictReader(file)
	    for row in csv_file:
	    	notary_seeds.append(dict(row))
	return notary_seeds

def add_notaries():
	# Add to tracking
	for notary in notary_seeds:
		params = {
			"mmrpc": "2.0",
			"params": {
				"name":notary["notary"],
				"address":notary["3P IP Address"],
				"peer_id":notary["PeerID"]
			}
		}
		r = mm2_proxy('add_node_to_version_stat', params)

def start_stats_collection():
	params = {
		"mmrpc": "2.0",
		"params": {
			"interval":60,
		}
	}
	print("Starting stats collection...")
	r = mm2_proxy('start_version_stat_collection', params)

def empty_table():
	rows = cursor.execute("DELETE FROM stats_nodes;")
	conn.commit()
	print('Deleted', cursor.rowcount, 'records from the table.')

def get_version_stats_from_db():
	rows = cursor.execute("SELECT * FROM stats_nodes WHERE version != ''").fetchall()
	for row in rows:
	    print(dict(row))

if __name__ == '__main__':
	if len(sys.argv) > 1:
		if sys.argv[1] == 'empty':
			empty_table()
		if sys.argv[1] == 'start':
			start_stats_collection()
	get_version_stats_from_db()
conn.close()