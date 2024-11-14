#!/bin/bash
CONDA_MIRROR="https://mirrors.zju.edu.cn/anaconda/"
CONDA_SH="miniconda/Miniconda3-latest-Linux-x86_64.sh"
CONDA_PATH="/opt/miniconda"

# The conda installation file must end with .sh, otherwise an error will occur, see the source code
tmpfile=$(mktemp).sh
if ! wget -O "$tmpfile" "$CONDA_MIRROR$CONDA_SH"; then
	echo "Failed to download $MIRROR$CONDA_SH"
	exit 1
fi

bash "$tmpfile" -b -p "$CONDA_PATH"
rm "$tmpfile"

cat >>$CONDA_PATH/.condarc <<EOF
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.zju.edu.cn/anaconda/pkgs/main
  - https://mirrors.zju.edu.cn/anaconda/pkgs/r
  - https://mirrors.zju.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.zju.edu.cn/anaconda/cloud
  msys2: https://mirrors.zju.edu.cn/anaconda/cloud
  bioconda: https://mirrors.zju.edu.cn/anaconda/cloud
  menpo: https://mirrors.zju.edu.cn/anaconda/cloud
  pytorch: https://mirrors.zju.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.zju.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.zju.edu.cn/anaconda/cloud
  nvidia: https://mirrors.zju.edu.cn/anaconda-r
EOF
