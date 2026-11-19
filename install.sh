#!/bin/sh
set -eu

repo=$(CDPATH= cd "$(dirname "$0")" && pwd)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
mkdir -p "$config_home"

link_config() {
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    mv "$2" "$2.backup-$(date +%Y%m%d%H%M%S)"
  fi
  ln -sfn "$1" "$2"
}

link_config "$repo/_vim" "$config_home/vim"
link_config "$repo/_ctags.d" "$HOME/.ctags.d"
