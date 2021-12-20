#!/bin/bash

#checks to see if it is ran as root. We need to be ran as root so that netplan, hostname
# adduser, and usermod work correctly
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if [ -d ".ssh" ]; then #if the .ssh folder exists, just append the contents from keys.txt
        cat keys.txt >> .ssh/authorized_keys
        echo "Folder exists"
else #if the .ssh folder exists, just append the contents from keys.txt
        mkdir -p .ssh;
        cat keys.txt >> .ssh/authorized_keys
        echo "folder created"
fi

echo "What do you want to make the ip address?";
read ip;

VAR1='s/192.168.1.249/' #ip address that is in the .yaml file of the vm clone
VAR2=$ip
VAR3='/g /etc/netplan/00-installer-config.yaml'

echo $VAR1$VAR2$VAR3

echo "What do you want the new username to be?";
read username;

echo "What do you want the new password to be?";
read password;

VAR4='s/password/'
VAR5=$password
VAR6='/g ./users.txt'

echo "What do you want the new hostname to be?";
read hostname;
hostnamectl set-hostname $hostname
VAR7='s/ubuntuserver/'
VAR8=$hostname
VAR9='/g /etc/hosts'

sudo sed -i $VAR7$VAR8$VAR9

echo "set hostname"

#apply new network settings
sudo sed -i $VAR1$VAR2$VAR3
echo "set ip addr"

#replace password in text file
sudo sed -i $VAR4$VAR5$VAR6

#add new user
sudo adduser ${username} < ./users.txt;
echo "added user"

#add user to sudoers file to allow for use of sudo
sudo usermod -aG sudo ${username}
echo "added user to sudo group"

read -p "Do you want to update the system? [y/n] " -n 1 -r
echo    # (optional) move to a new line

read -p   "Do you want to reboot or shutdown? [r/s (default r)] " -n 1 -r rs
echo    # (optional) move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]; then
        export DEBIAN_FRONTEND=noninteractive
        sudo apt-get update && sudo apt-get -y upgrade;
fi

#file cleanup to remove everything after all tasks completed
rm users.txt
rm change.sh
rm keys.txt

case $rs in
        [Rr]* ) sudo reboot;;
        [Ss]* ) sudo shutdown -h now;;
        * ) sudo reboot;;
esac
