#!/bin/bash
grep -vE "^#" pkgs.txt | sed 's/ /\n/g' | sort | tr '\n' ' ' | fold -w 80 -s | tee tmp.txt
sed 's/ /\n/g' tmp.txt | grep -Ev "^$" > pkgs.txt
rm tmp.txt
