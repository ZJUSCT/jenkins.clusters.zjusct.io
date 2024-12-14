#!/bin/bash

debian(){
	install_pkg munge slurmd
}

ubuntu(){
	debian
}

check_and_exec "$ID"
