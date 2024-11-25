#!/bin/bash

# we change zsh to read profile.d as bash does
# https://lmod.readthedocs.io/en/latest/030_installing.html#zsh
cat > /etc/zsh/zshenv <<'EOF'
if [ -d /etc/profile.d ]; then
  setopt no_nomatch
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  setopt nomatch
fi
EOF
