#!/bin/bash
#
# pimp.bash
#
# v0.0.1 - 2021-02-24 - nelbren@nelbren.com
#

inform_task() {
  case $2 in
    1) echo -e "\e[30;48;5;3m$1!\e[0m\e[K";;
    2) echo -e "\e[7;49;93m$1:\e[0m\e[K";;
    *) echo -en "\e[30;48;5;7m$1...\e[0m\e[K"
  esac
}

inform_and_exit() {
  if [ "$1" == "0" ]; then
    echo -e "\e[7;49;92mOK\e[0m\e[K"
  else
    echo -e "\e[1;48;5;1m$2\e[0m\e[K"
    exit $1
  fi
}

check_if_normal_user_running() {
  inform_task "Am I running as a 'normal' user?"
  [[ "$(id -u)" == "0" ]] && e=1 || e=0
  inform_and_exit $e "NO!"
}

sudo_test_access_to_user() {
  user=$USER
  inform_task "Let's test if the '$user' can run sudo"
  id=$(sudo id -u)
  inform_and_exit $id "Problem checking if user can access 'sudo'"
}

apt_install_package() {
  inform_task "Is the '$1' package installed?"
  if dpkg -s $1 2>/dev/null 1>&2 ; then
    inform_and_exit 0 ""
  else
    inform_task "NO" 1
    inform_task "Ok, no problem, i will install '$1' package" 2
    sudo apt install -y $1
    inform_task "Is the '$1' package installed?"
    if dpkg -s $1 2>/dev/null 1>&2 ; then
      inform_and_exit 0 ""
    else
      inform_and_exit $? "Problem installing '$1'!"
    fi
  fi
}

misc_install_package() {
  packages="cowsay fortunes-es fortunes-es-off fortunes-debian-hints lolcat cmatrix"
  for package in $packages; do
    apt_install_package $package
  done
}

cowsay_profile_install() {
  file=/etc/profile
  line="/usr/local/npres/bin/enable/hola.bash"
  inform_task "Exist 'cowsay' in '$file'?"
  if sudo grep -q "$line" $file; then
    inform_and_exit 0 ""
  else
    inform_task "NO" 1
    inform_task "Ok, no problem, I'll do it for you, watch memes in the meantime" 2
    echo "$line" | sudo tee -a $file > /dev/null
    inform_task "Exist 'cowsay' in '$file'?"
    if sudo grep -q "$line" $file; then
      inform_and_exit 0 ""
    else
      inform_and_exit $? "Problem adding 'cowsay' to '$file'!"
    fi
  fi
}

line_uncomment() {
  sudo sed -i "s/$1/${1:1}/" $2
}

colors_bashrc_enable() {
  files="$HOME/.bashrc /etc/skel/.bashrc"
  for file in $files; do
    inform_task "Uncomment colors in '$file'?"
    line_uncomment "#alias grep='grep --color=auto'" $file
    line_uncomment "#alias fgrep='fgrep --color=auto'" $file
    line_uncomment "#alias egrep='egrep --color=auto'" $file
    line_uncomment "#alias ll='ls -l'" $file
    line_uncomment "#alias la='ls -A'" $file
    line_uncomment "#alias l='ls -CF'" $file
    inform_and_exit 0 ""
  done

  file=/root/.bashrc
  inform_task "Uncomment colors in '$file'?"
  line_uncomment "# export LS_OPTIONS='--color=auto'" $file
  line_uncomment "# eval \"\`dircolors\`\"" $file
  line_uncomment "# alias ls='ls \$LS_OPTIONS'" $file
  line_uncomment "# alias ll='ls \$LS_OPTIONS -l'" $file
  line_uncomment "# alias l='ls \$LS_OPTIONS -lA'" $file
  inform_and_exit 0 ""
}

line_add() {
  file=$1
  line="cmatrix -sb -C $2"
  inform_task "Exist 'cmatrix' in '$file'?"
  if sudo grep -q "$line" $file; then
    inform_and_exit 0 ""
  else
    inform_task "NO" 1
    inform_task "Ok, no problem, I'll do it for you, watch memes in the meantime" 2
    echo "$line" | sudo tee -a $file > /dev/null
    inform_task "Exist 'cmatrix' in '$file'?"
    if sudo grep -q "$line" $file; then
      inform_and_exit 0 ""
    else
      inform_and_exit $? "Problem adding 'cmatrix' to '$file'!"
    fi
  fi
}

cmatrix_bashrc_install() {
  line_add ~/.bashrc green
  line_add /etc/skel/.bashrc green
  line_add /root/.bashrc red
}

git_install_package() {
  inform_task "Is the 'git' package installed?"
  if dpkg -s git 2>/dev/null 1>&2 ; then
    inform_and_exit 0 ""
  else
    inform_task "NO" 1
    inform_task "Ok, no problem, i will install 'git' package" 2
    sudo apt install -y git
    inform_task "Is the 'git' package installed?"
    if dpkg -s git 2>/dev/null 1>&2 ; then
      inform_and_exit 0 ""
    else
      inform_and_exit $? "Problem installing git!"
    fi
  fi
}

npres_git_clone() {
  dir=/usr/local/npres
  inform_task "Exist the '$dir' directory?"
  if [ -d $dir ]; then
    inform_and_exit 0 ""
    inform_task "Ok, i will update the 'yapf' repo" 2
    cd $dir
    sudo git pull
    e=$?
    inform_task "Is the 'yafp' repo updated?"
    inform_and_exit $e "Problem updating 'yapf' repo!"
  else
    inform_task "NO" 1
    inform_task "Ok, no problem, i will clone the 'yapf' repo" 2
    sudo git clone https://github.com/nelbren/npres.git $dir
    inform_task "Exist the '$dir' directory?"
    if [ -d $dir ]; then
      inform_and_exit 0 ""
    else
      inform_and_exit $? "Problem cloning 'yapf' repo!"
    fi
  fi
}

check_if_normal_user_running
sudo_test_access_to_user
misc_install_package
git_install_package
npres_git_clone
cowsay_profile_install
colors_bashrc_enable
