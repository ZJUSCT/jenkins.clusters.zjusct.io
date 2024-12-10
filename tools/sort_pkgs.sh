#!/bin/bash
grep -vE "^#" common.txt | sed 's/ /\n/g' | sort | tr '\n' ' ' | fold -w 80 -s
