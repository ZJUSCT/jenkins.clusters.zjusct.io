#!/bin/bash
sed 's/ /\n/g' /tmp/pkgs | sort | tr '\n' ' ' | fold -w 80 -s
