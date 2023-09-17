#!/bin/bash

# Check if OpenVPN is already installed
if [ -e /etc/openvpn/server.conf ]; then
    echo "OpenVPN is already installed. Exiting."
    exit 0
fi

# Update system and install openvpn and easy-rsa
sudo apt-get update
sudo apt-get -y install openvpn easy-rsa

# Make the server configuration directory
mkdir -p /etc/openvpn/server

# Generate server key and certificate
make-cadir /etc/openvpn/server/easy-rsa
cd /etc/openvpn/server/easy-rsa
source ./vars
./clean-all
./build-ca
./build-key-server server

# Generate Diffie-Hellman parameters
./build-dh

# Move server keys and certificates
cp /etc/openvpn/server/easy-rsa/keys/{server.crt,server.key,ca.crt,dh2048.pem} /etc/openvpn/server/

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-openvpn.conf
sysctl -p /etc/sysctl.d/99-openvpn.conf

# Configure and start OpenVPN
echo "port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
server 10.8.0.0 255.255.255.0
push \"redirect-gateway def1 bypass-dhcp\"
push \"dhcp-option DNS 208.67.222.222\"
push \"dhcp-option DNS 208.67.220.220\"
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
client-to-client" > /etc/openvpn/server/server.conf

# Start OpenVPN
systemctl start openvpn@server
systemctl enable openvpn@server
