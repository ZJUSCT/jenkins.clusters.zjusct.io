#!/bin/bash

pacman --noconfirm -Scc
sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf