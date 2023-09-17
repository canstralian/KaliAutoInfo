#!/bin/bash

# Check and install Wireshark if not exists
if ! command -v wireshark &> /dev/null
then
    echo "Wireshark is not installed. Proceeding to install."
    sudo apt install -y wireshark
else
    echo "Wireshark is already installed. Proceeding with the script."
fi

# Check if running as root
if [ "$(id -u)" != "0" ]; then
  echo "Please run as root." 
  exit 1
fi

# Check if WireGuard is already installed
if [ "$(wg)" ]; then
  echo "WireGuard is already installed." 
  exit 1
fi

# Installation steps for Ubuntu/Debian based distributions
if [ "$(uname -s)" = "Linux" ]; then
  apt-get update
  apt-get install -y wireguard
fi

# Generate WireGuard keys
umask 077
wg genkey > /etc/wireguard/privatekey
wg pubkey < /etc/wireguard/privatekey > /etc/wireguard/publickey

# Set up WireGuard configuration
echo "[Interface]
PrivateKey = $(cat /etc/wireguard/privatekey)
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = $(cat /etc/wireguard/publickey)
AllowedIPs = 10.0.0.0/24" > /etc/wireguard/wg0.conf

# Enable and start WireGuard
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
systemctl status wg-quick@wg0

# Set up iptables rules for proper routing
# '-I' option inserts the rule at the top of the chain
sudo iptables -I FORWARD -i wg0 -j ACCEPT
sudo iptables -I FORWARD -i eth0 -j ACCEPT
#  Add similar lines for other network interfaces (eth1, eth2, etc.) if necessary  