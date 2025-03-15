#!/bin/bash

# shellcheck disable=SC1090
source ~/repology/bin/activate
# ./query.py -p pkgs.txt -r repos.txt
./query.py -v pkgs.txt -r repos.txt
