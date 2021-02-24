#!/bin/bash

hola_user() {
  /usr/games/fortune /usr/share/games/fortunes/es /usr/share/games/fortunes/es/off | /usr/games/cowsay -d | /usr/games/lolcat
  cmatrix -sb -C green
}

hola_root() {
  neofetch
  cmatrix -sb -C red
}

man_colors() {
  export LESS_TERMCAP_mb=$'\e[1;32m'
  export LESS_TERMCAP_md=$'\e[1;32m'
  export LESS_TERMCAP_me=$'\e[0m'
  export LESS_TERMCAP_se=$'\e[0m'
  export LESS_TERMCAP_so=$'\e[01;33m'
  export LESS_TERMCAP_ue=$'\e[0m'
  export LESS_TERMCAP_us=$'\e[1;4;31m'
}

man_colors

if [ "$USER" == "root" ]; then
  hola_root
else
  hola_user
fi
