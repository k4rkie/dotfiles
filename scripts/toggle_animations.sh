#!/usr/bin/env bash

path_to_config=$HOME/dotfiles/mango/config.conf
is_animations_on="$(grep -m 1 'animations=' $path_to_config | cut -d = -f 2)"

if [ $is_animations_on == 0 ]; then
  sed -i "s/animations=0/animations=1/" $path_to_config > /dev/null
else
  sed -i "s/animations=1/animations=0/" $path_to_config > /dev/null
fi

mmsg dispatch reload_config
