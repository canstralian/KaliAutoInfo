#!/bin/bash
# Path: rosybrown.sh
# Description: Modular Bash automation system for network recon, auditing, and file crypto tasks.

set -euo pipefail

# Install dependencies if missing
required_tools=("nmap" "gpg" "whois" "dig" "cracklib-check" "lolcat")
for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        echo "[*] Installing $tool..."
        sudo apt-get update && sudo apt-get install -y "$tool"
    fi
done

# Banner with lolcat fallback
function banner() {
    msg="===== RosybrownJoyousAutomatedinformationsystem ====="
    if command -v lolcat &>/dev/null; then
        echo "$msg" | lolcat
    else
        echo "$msg"
    fi
}

# Validate IP or domain using regex
function validate_ip_or_domain() {
    local input="$1"
    [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ || "$input" =~ ^[a-zA-Z0-9.-]+$ ]]
}

# Validate port range
function validate_port_range() {
    [[ "$1" =~ ^[0-9]+-[0-9]+$ ]]
}

# Network scanning and discovery with sanitized input and optional logging
function network_scan() {
    read -rp "Enter the IP range to scan (e.g., 192.168.1.0/24): " ip_range

    if ! validate_ip_or_domain "$ip_range"; then
        echo "Invalid IP range format."
        return
    fi

    read -rp "Save output to file? (y/n): " save_opt
    if [[ "$save_opt" =~ ^[Yy]$ ]]; then
        read -rp "Enter output file name: " out_file
        nmap -p 1-65535 -sS -Pn --open "$ip_range" -oN "$out_file"
        echo "Results saved to $out_file"
    else
        nmap -p 1-65535 -sS -Pn --open "$ip_range"
    fi
}

# Port scanning with validation
function port_scan() {
    read -rp "Enter the IP address to scan: " ip_address
    if ! validate_ip_or_domain "$ip_address"; then
        echo "Invalid IP address."
        return
    fi

    read -rp "Enter the port range to scan (e.g., 20-1024): " port_range
    if ! validate_port_range "$port_range"; then
        echo "Invalid port range."
        return
    fi

    read -rp "Save output to file? (y/n): " save_opt
    if [[ "$save_opt" =~ ^[Yy]$ ]]; then
        read -rp "Enter output file name: " out_file
        nmap -p "$port_range" "$ip_address" --open -oN "$out_file"
        echo "Results saved to $out_file"
    else
        nmap -p "$port_range" "$ip_address" --open
    fi
}

# Password auditing using cracklib
function password_audit() {
    password_file="passwords.txt"

    if [[ ! -f "$password_file" || ! -s "$password_file" ]]; then
        echo "Password file '$password_file' not found or empty."
        return
    fi

    while IFS= read -r password; do
        [[ -z "$password" ]] && continue
        strength=$(cracklib-check <<< "$password" | awk -F': ' '{print $2}')
        echo "Password: $password | Strength: $strength"
    done < "$password_file"
}

# File encryption and decryption
function file_manipulation() {
    read -rp "Enter the file name (without extension): " file
    sanitized_file=$(basename "$file")

    echo "1. Encrypt file"
    echo "2. Decrypt file"
    read -rp "Choose an option (1-2): " option

    case $option in
        1)
            [[ -f "$sanitized_file" ]] && gpg -c "$sanitized_file" || echo "File not found."
            ;;
        2)
            [[ -f "$sanitized_file.gpg" ]] && gpg "$sanitized_file.gpg" || echo "Encrypted file not found."
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

# WHOIS lookup with input sanitization
function whois_lookup() {
    read -rp "Enter a domain or IP address: " target
    if validate_ip_or_domain "$target"; then
        whois "$target"
    else
        echo "Invalid input."
    fi
}

# DNS lookup with validation
function dns_lookup() {
    read -rp "Enter a domain name: " target
    if validate_ip_or_domain "$target"; then
        dig "$target" +short
    else
        echo "Invalid domain name."
    fi
}

# Main menu
function main_menu() {
    while true; do
        banner
        echo "1. Network scanning and discovery"
        echo "2. Port scanning"
        echo "3. Password auditing"
        echo "4. File manipulation"
        echo "5. WHOIS lookup"
        echo "6. DNS Lookup"
        echo "7. Exit"
        read -rp "Choose an option: " option

        case $option in
            1) network_scan ;;
            2) port_scan ;;
            3) password_audit ;;
            4) file_manipulation ;;
            5) whois_lookup ;;
            6) dns_lookup ;;
            7) echo "Exiting. Stay secure!" && exit 0 ;;
            *) echo "Invalid option. Try again!" ;;
        esac
    done
}

# Start the script
main_menu