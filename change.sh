#!/bin/sh

#checks to see if it is ran as root. We need to be ran as root so that netplan, hostname
# adduser, and usermod work correctly
if [ "$(id -u)" -ne 0 ]; then
   printf "This script must be run as root"
   exit 1
fi

printf "What do you want to make the ip address? "
read -r ip

printf "What do you want the new username to be? "
read -r username

# Read in a password without printing the characters
stty -echo
printf "What do you want the new password to be? "
read -r password
stty echo
printf "\n" # Move to a new line

printf "What do you want the new hostname to be? "
read -r hostname

printf "Do you want to update the system? [y/n] "
read -r reply

printf "Do you want to reboot or shutdown? [r/s (default r)] "
read -r rs

printf "\n\n"   # Move to a new line

hostnamectl set-hostname "${hostname}"

sudo sed -i "s/ubuntuserver/${hostname}/g" /etc/hosts

printf "\nset hostname\n"

# Apply new network settings
sudo sed -i "s/192.168.1.249/${ip}/g" "/etc/netplan/00-installer-config.yaml"
printf "set ip addr\n"

# Add new user
sudo useradd -m -d "/home/${username}" "${username}" -p "$(openssl passwd -1 "${password}")" -s /bin/bash
printf "added user %s" "${username}\n"

# Add user to sudoers file to allow for use of sudo
sudo usermod -aG sudo "${username}"
printf "added %s to the sudo group" "${username}\n"

# If the reply is either 'Y' or 'y' then update the system
case "${reply}" in
        [Yy]* ) sudo apt-get update && sudo apt-get -y upgrade;;
        * ) printf "Nothing needs to be done\n";;
esac

# File cleanup to remove everything after all tasks completed
rm change.sh

sleep 1

# Reboot or shutdown, but default to just a reboot
case ${rs} in
        [Rr]* ) sudo reboot;;
        [Ss]* ) sudo shutdown -h now;;
        * ) sudo reboot;;
esac
