#!/bin/bash
rm mm2
wget $(curl -vvv https://api.github.com/repos/KomodoPlatform/komodo-defi-framework/releases | jq -r '.[0].assets | map(select(.name | contains("Linux-Release."))) | .[0].browser_download_url') -O mm2.zip
unzip mm2.zip
rm mm2.zip
sudo ufw allow 42845 comment 'MM2 Seednode TCP'
sudo ufw allow 42855 comment 'MM2 Seednode WSS'
echo "Please run ./update_conf.py before restarting './mm2' to update your NetID."
