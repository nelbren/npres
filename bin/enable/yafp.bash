#!/bin/bash
#
# yafp.bash
#
#
# v0.0.1 - 2021-02-23 - nelbren@nelbren.com
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

yafp_git_clone() {
  dir=/usr/local/yafp
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
    sudo git clone https://github.com/nelbren/yafp.git $dir
    inform_task "Exist the '$dir' directory?"
    if [ -d $dir ]; then
      inform_and_exit 0 ""
    else
      inform_and_exit $? "Problem cloning 'yapf' repo!"
    fi
  fi
}

validate() {
  line="source /usr/local/yafp/yafp-ps1.bash"
  inform_task "Exist 'yafp-ps1.bash' in '$1'?"
  if sudo grep -q "$line" $1; then
    inform_and_exit 0 ""
  else
    inform_task "NO" 1
    inform_task "Ok, no problem, I'll do it for you, watch memes in the meantime" 2
    echo "$line" | sudo tee -a $1 > /dev/null
    inform_task "Exist 'yafp-ps1.bash' in '$1'?"
    if sudo grep -q "$line" $1; then
      inform_and_exit 0 ""
    else
      inform_and_exit $? "Problem adding 'yapf' to '$1'!"
    fi
  fi
}

yafp_bashrc_install() {
  validate ~/.bashrc
  validate /etc/skel/.bashrc
  validate /root/.bashrc
}

check_if_normal_user_running
sudo_test_access_to_user
git_install_package
yafp_git_clone
yafp_bashrc_install
