#!/bin/bash
rm mm2
#wget $(curl -vvv https://api.github.com/repos/KomodoPlatform/atomicDEX-API/releases | jq -r '.[0].assets | map(select(.name | contains("Linux-Release."))) | .[0].browser_download_url') -O mm2.zip
wget http://195.201.0.6/dev/mm2-4366141c8-Linux-Release.zip -O mm2.zip
unzip mm2.zip
rm mm2.zip
