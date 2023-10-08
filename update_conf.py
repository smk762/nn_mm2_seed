#!/usr/bin/env python3
import time
import json
import os.path

if os.path.exists("MM2.json"):
    conf = json.load(open("MM2.json"))
    fn = f"MM2_backup_{int(time.time())}.json"
    json.dump(conf, open(fn, "w+"), indent=4)
    print(f"Old MM2,json file backed up as {fn}")
    conf.update({
        "netid": 8762,
        "seednodes": [
            "streamseed1.komodo.earth",
            "streamseed2.komodo.earth",
            "streamseed3.komodo.earth",
            "streamwatchtower1.komodo.earth"
        ]
    })

    with open("MM2.json", "w+") as f:
        json.dump(conf, f, indent=4)

    print("MM2.json file updated for netID 8762!")
else:
    print("MM2.json file not found! Please run ./gen_conf.py first.")
