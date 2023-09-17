#!/bin/bash

# Update packages and Upgrade system
# apt-get command is used to handle packages in Linux.
# 'update' option is used to resynchronize the package index files from their sources via Internet.
# 'upgrade' option is used to install the newest versions of all packages currently installed on the system.
sudo apt-get update -y
sudo apt-get upgrade -y

# Install XRDP
# XRDP is an Open Source Remote Desktop Protocol Server, allowing RDP clients to be presented an Xwindows Desktop to the user.
sudo apt-get install -y xrdp

# Start XRDP Service on boot up
sudo systemctl start xrdp
sudo systemctl enable xrdp

# Download OpenVPN installation script
# wget command is used to download files from the network.
# '-O' option is used to specify the name of the file in which to save the download.
wget https://git.io/vpn -O openvpn-install.sh

# Make the downloaded script executable
# chmod command is used to change the permissions of a file.
# '+x' option is used to make the file executable.
chmod +x openvpn-install.sh

# Run OpenVPN installation script
sudo ./openvpn-install.sh

#Enable OpenVPN to run on startup
sudo systemctl enable openvpn

# Starting OpenVPN service
sudo systemctl start openvpn

# Download WireGuard installation script
wget https://git.io/wg -O wireguard-install.sh

# Make the script executable
chmod +x wireguard-install.sh

# Run WireGuard Install Script
sudo ./wireguard-install.sh

# Install WireGuard and its tools
sudo apt-get install -y wireguard
sudo apt-get install -y wireguard-tools

# Enable WireGuard to run on startup and then start the service immediately
sudo systemctl enable wireguard
sudo systemctl start wireguard

# Setting up iptables rules for proper routing
# '-I' option inserts the rule at the top of the chain
sudo iptables -I FORWARD -i wg0 -j ACCEPT
sudo iptables -I FORWARD -i eth0 -j ACCEPT
#  Add similar lines for other network interfaces (eth1, eth2, etc.) if necessary

# Terminate rest of the script here
# Rest of the lines seem to be repeating commands for non-existent services, removing them for script optimization
sudo systemctl stop wireguard
sudo systemctl stop openvpn
sudo systemctl disable wireguard
sudo systemctl disable openvpn
sudo rm -rf openvpn-install.sh
sudo rm -rf wireguard-install.sh

