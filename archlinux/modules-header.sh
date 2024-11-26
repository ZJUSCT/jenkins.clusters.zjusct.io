#!/usr/bin/env bash

shopt -s expand_aliases
alias pacman="pacman --noconfirm"
alias curl="curl --retry-all-errors --retry 5 --silent --show-error --location"
