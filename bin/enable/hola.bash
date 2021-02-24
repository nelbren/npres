#!/bin/bash

hola_user() {
  /usr/games/fortune /usr/share/games/fortunes/es /usr/share/games/fortunes/es/off | /usr/games/cowsay -d | /usr/games/lolcat
  cmatrix -sb -C green
}

hola_root() {
  neofetch
  cmatrix -sb -C red
}

if [ "$USER" == "root" ]; then
  hola_root
else
  hola_user
fi
