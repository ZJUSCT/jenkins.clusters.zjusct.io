#!/bin/bash

aria2c --max-connection-per-server=16 --split=16 --min-split-size=1M --continue=true --auto-file-renaming=false --dir=/ocean/download --input-file=runfile.list
