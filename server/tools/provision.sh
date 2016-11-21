#!/bin/bash
# 
# install stuff required for gpg-notebook server to function
#
# @version @package_version@
# @author Michael A. Trimm
# @website https://github.com/michaeltrimm
#
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;33m'
LIGHTBLUE='\033[1;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

set -o errexit

# Script requires root for access to /etc/hosts
if [ "$EUID" -ne 0 ]
  then printf "Please run as ${RED}root${NC} using ${YELLOW}sudo /vagrant/tools/provision.sh${NC}\n\n"
  exit
fi

function update_apt {
  DEBIAN_FRONTEND="noninteractive" apt-get update
  DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y
}

function install_deps {
  DEBIAN_FRONTEND="noninteractive" apt-get install apt-transport-https ca-certificates -y
  apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070AD
}

function install_docker {
  DEBIAN_FRONTEND="noninteractive" apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
  groupadd docker
  usermod -aG docker vagrant

  DEBIAN_FRONTEND="noninteractive" apt-get install docker-engine
  
  systemctl enable docker
  service docker start
}

function protect_system {
  
  
  
  DEBIAN_FRONTEND="noninteractive" apt-get install fail2ban -y
  systemctl enable fail2ban
  service fail2ban start
  
  DEBIAN_FRONTEND="noninteractive" apt-get install vim -y
  DEBIAN_FRONTEND="noninteractive" apt-get install logrotate -y
  systemctl enable logrotate
  service start logrotate
  
  ufw enable
  ufw default deny incoming
  ufw default allow outgoing
}

function readme {
  printf "Provisioning GPG Notebook\n"
  printf "\n${GREEN}"
  printf "██╗  ██╗███████╗██╗     ██████╗ \n"
  printf "██║  ██║██╔════╝██║     ██╔══██╗\n"
  printf "███████║█████╗  ██║     ██████╔╝\n"
  printf "██╔══██║██╔══╝  ██║     ██╔═══╝ \n"
  printf "██║  ██║███████╗███████╗██║     \n"
  printf "╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     \n"
  printf "${NC}\n"
  printf "\n"
  printf "${BLUE}@author${NC} Michael Trimm <${CYAN}michael@michaeltrimm.com${NC}>\n"
  printf "${BLUE}@website${NC} ${CYAN}https://github.com/michaeltrimm${NC}\n"
  printf "${BLUE}@project${NC} ${CYAN}https://github.com/michaeltrimm/gpg-notebook/server${NC}\n"
  printf "${BLUE}@note${NC} No support will be provided under any circumstance\n"
  printf "${BLUE}@license${NC} MIT\n"
  printf "\n"
  printf "Usage: \n"
  printf "\n"
  printf "    Show the help menu...\n"
  printf "    ${GREEN}sudo ./provision.sh --help${NC}\n"
  printf "\n"
  printf "    Provision the system\n"
  printf "    ${GREEN}sudo ./provision.sh --provision${NC}\n"
  printf "\n"
  printf "    Revert to the previous state of your hosts file\n"
  printf "    ${RED}sudo ./run.sh --undo${NC}\n"
  printf "\n"
  printf "    Uninstalls the entire script and reverts to original\n"
  printf "    ${RED}sudo ./run.sh --uninstall${NC}\n"
  printf "\n\n"
  exit
}

# If no args are specified, show the readme
if [ -z "$*" ]; then readme; exit; fi

# CLI Arguments Handler
for i in "$@"
do
case $i in
    --install)
    install
    shift
    ;;
    --undo)
    undo
    shift
    ;;
    --uninstall)
    uninstall
    shift
    ;;
    -h|--help)
    readme
    shift
    ;;
    *)
    readme
    ;;
esac
done

# Always end positive
exit 1
