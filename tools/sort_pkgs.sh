#!/bin/bash
grep -vE "^#" common.txt | sed 's/ /\n/g' | sort | tr '\n' ' ' | fold -w 80 -s | tee sorted_common.txt
sed 's/ /\n/g' sorted_common.txt | grep -Ev "^$" > common.txt
rm sorted_common.txt
