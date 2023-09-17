#!/bin/bash

# Install lolcat if it isn't installed
if ! command -v lolcat &> /dev/null
then
    sudo apt install lolcat -y
fi

# Network scanning and discovery
function network_scan() {
    read -p "Enter the IP range to scan (e.g., 192.168.0.1-254): " ip_range
    nmap -p 1-65535 -sS -Pn $ip_range
}

# Port scanning
function port_scan() {
    read -p "Enter the IP address to scan (e.g., 192.168.0.1): " ip_address
    read -p "Enter the port range to scan (e.g., 1-65535): " port_range
    nmap -p $port_range $ip_address
}

# Password auditing
function password_audit() {
    password_file="passwords.txt"

    while IFS= read -r password; do
        strength=$(cracklib-check <<< "$password" | awk '{print $2}')
        echo "Password: $password | Strength: $strength"
    done < "$password_file"
}

# File encryption and decryption
function file_manipulation() {
    file="secret.txt"

    echo "1. Encrypt file"
    echo "2. Decrypt file"
    read -p "Choose an option (1-2): " option

    case $option in
        1) gpg -c "$file" ;;
        2) gpg "$file.gpg" ;;
        *) echo "Invalid option" ;;
    esac
}

# WHOIS lookup
function whois_lookup() {
    read -p "Enter a domain or IP address: " target
    whois "$target"
}

# DNS lookup
function dns_lookup() {
    read -p "Enter a domain name: " target
    dig "$target"
}

# Main menu
function main_menu() {
    while true; do
        echo "===== Welcome to RosybrownJoyousAutomatedinformationsystem ====="
        echo "1. Network scanning and discovery"
        echo "2. Port scanning"
        echo "3. Password auditing"
        echo "4. File manipulation"
        echo "5. WHOIS lookup"
        echo "6. DNS Lookup"
        echo "7. Exit"
        read -p "Choose an option: " option

        case $option in
            1) network_scan;;
            2) port_scan ;;
            3) password_audit ;;
            4) file_manipulation ;;
            5) whois_lookup ;;
            6) dns_lookup ;;
            7) exit ;;
            *) echo "Invalid option. Try again!" ;;
        esac
    done
}

# Start the script
main_menu
exit 0
