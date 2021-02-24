#!/bin/bash
#
# enable_sudo.bash
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

check_if_root_running() {
  inform_task "Am I running as 'root'?"
  inform_and_exit $(id -u) "Run with 'root' user, because i need to install sudo"
}

sudo_install_package() {
  inform_task "Is the 'sudo' package installed?"
  if dpkg -s sudo 2>/dev/null 1>&2 ; then
    inform_and_exit 0 ""
  else
    inform_task "NO" 1
    inform_task "Ok, no problem, i will install 'sudo' package" 2
    apt install -y sudo
    inform_task "Is the 'sudo' package installed?"
    if dpkg -s sudo 2>/dev/null 1>&2 ; then
      inform_and_exit 0 ""
    else
      inform_and_exit $? "Problem installing sudo!"
    fi
  fi
}

sudo_disable_password() {
  inform_task "Now, i will disable the ask password in sudo"
  sed -Ei "s/(^%sudo.*) ALL/\1 NOPASSWD:ALL/" /etc/sudoers
  inform_and_exit $? "Problem disassibling password!"
}

sudo_add_to_sudo_group() {
  user=$(who am i | cut -d" " -f1)
  inform_task "It is the turn to add the '$user' to the 'sudo' group"
  if groups $user | grep -q sudo ; then
    inform_and_exit 0 ""
  else
    inform_task "NO" 1
    inform_task "Ok, no problem, i will add the '$user' to sudo group" 2
    usermod -aG sudo $user
    inform_task "It is the turn to add the '$user' to the 'sudo' group"
    if groups $user | grep -q sudo ; then
      inform_and_exit 0 ""
    else
      inform_and_exit $? "Problem adding to sudo group!"
    fi
  fi
}

sudo_test_access_to_user() {
  user=$(who am i | cut -d" " -f1)
  inform_task "Let's test if the '$user' is in the sudo group"
  if su $user -c groups | grep -q sudo ; then
    inform_and_exit 0 ""
  else
    inform_and_exit 2 "Problem checking if user has 'sudo' group!"
  fi
  inform_task "Let's test if the '$user' can run sudo"
  id=$(su $user -c "sudo id -u")
  inform_and_exit $id "Problem checking if user can access 'sudo'"
}

check_if_root_running
sudo_install_package
sudo_disable_password
sudo_add_to_sudo_group
sudo_test_access_to_user
