#!/bin/bash
# https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html
# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/
# https://developer.nvidia.com/cuda-downloads
NVIDIA_CUDA=http://storage/cuda.run
tmpfile=$(mktemp -u).run

wget "$NVIDIA_CUDA" -O "$tmpfile"
chmod +x "$tmpfile"

$tmpfile --silent --driver --toolkit
rm -f "$tmpfile"
