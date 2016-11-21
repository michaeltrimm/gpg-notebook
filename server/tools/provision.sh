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

NOW=$(date '+%Y%m%d@%H%M%S');

set -o errexit

# Script requires root for access to /etc/hosts
if [ "$EUID" -ne 0 ]
  then printf "Please run as ${RED}root${NC} using ${YELLOW}sudo /vagrant/tools/provision.sh${NC}\n\n"
  exit
fi

function update_apt {
  printf "Updating apt-get..."
  DEBIAN_FRONTEND="noninteractive" apt-get update 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Upgrading system packages..."
  DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
}

function install_deps {
  printf "Installing ${BLUE}apt-transport-https${NC} and ${BLUE}ca-certificates${NC}..."
  DEBIAN_FRONTEND="noninteractive" apt-get install apt-transport-https ca-certificates -y 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Installing Docker's signing key..."
  apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070AD 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
}

function install_docker {
  printf "Installing docker dependencies..."
  DEBIAN_FRONTEND="noninteractive" apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Creating new user group ${BLUE}docker${NC}..."
  groupadd docker 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Adding ${BLUE}vagrant${NC} user to the ${BLUE}docker${NC} group..."
  usermod -aG docker vagrant 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"

  printf "Installing the core ${RED}docker-engine${NC}..."
  DEBIAN_FRONTEND="noninteractive" apt-get install docker-engine 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Configuring ${RED}docker${NC} to start on system boot..."
  systemctl enable docker 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Starting ${RED}docker${NC} service..."
  service docker start 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
}

function protect_system {
  printf "Installing ${BLUE}fail2ban${NC}..."
  DEBIAN_FRONTEND="noninteractive" apt-get install fail2ban -y 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Configuring ${BLUE}fail2ban${NC} to start on system boot..."
  systemctl enable fail2ban 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Starting ${BLUE}fail2ban${NC} service..."
  service fail2ban start 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Updating ${BLUE}VIM${NC}..."
  DEBIAN_FRONTEND="noninteractive" apt-get install vim -y 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Installing ${BLUE}logrotate${NC}"
  DEBIAN_FRONTEND="noninteractive" apt-get install logrotate -y 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Configuring ${BLUE}logrotate${NC} to start on system boot..."
  systemctl enable logrotate 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Starting ${BLUE}logrotate${NC} service"
  service start logrotate 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Enabling ${BLUE}UFW${NC} firewall service..."
  ufw enable 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Setting firewall policy to deny all incoming connections by default..."
  ufw default deny incoming 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
  
  printf "Setting firewall policy to allow all outgoing connections by default..."
  ufw default allow outgoing 2> provision_${NOW}.log
  printf "${GREEN}✓${NC}\n"
}

function install {
  update_apt
  install_deps
  install_docker
  protect_system
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
