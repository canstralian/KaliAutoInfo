#!/usr/bin/env bash
# Path: rosybrown.sh
# Description: Modular Bash automation system for network recon, auditing, and file crypto tasks.

set -euo pipefail

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

# Install dependencies if missing, only if apt-get is available
required_tools=(nmap gpg whois dig cracklib-check lolcat)
if command -v apt-get &>/dev/null; then
  for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      echo "[*] Installing $tool..."
      sudo apt-get update && sudo apt-get install -y "$tool"
    fi
  done
fi

# Banner with lolcat fallback
banner() {
  local msg="===== Rosybrown Joyous Automated Information System ====="
  if command -v lolcat &>/dev/null; then
    echo "$msg" | lolcat
  else
    echo "$msg"
  fi
}

# Validate IPv4 or domain, allow optional CIDR, enforce ranges
validate_ip_or_domain() {
  local input="$1"
  # IPv4 CIDR: a.b.c.d/nn
  if [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$ ]]; then
    # Split IP and optional prefix
    IFS='/' read -r ip prefix <<< "$input"
    # Check each octet ≤255
    IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
    for o in $o1 $o2 $o3 $o4; do
      (( o >= 0 && o <= 255 )) || return 1
    done
    # If prefix present, must be 0–32
    if [[ -n "${prefix:-}" ]]; then
      (( prefix >= 0 && prefix <= 32 )) || return 1
    fi
    return 0
  fi
  # Basic domain: letters, numbers, hyphens, dots; must start/end letter/number
  if [[ "$input" =~ ^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?(\.[A-Za-z]{2,})+$ ]]; then
    return 0
  fi
  return 1
}

# Validate port range and numeric bounds
validate_port_range() {
  local pr="$1"
  if [[ "$pr" =~ ^([0-9]+)-([0-9]+)$ ]]; then
    local p1=${BASH_REMATCH[1]}
    local p2=${BASH_REMATCH[2]}
    # Check numeric bounds
    if (( p1 >= 1 && p1 <= 65535 && p2 >= 1 && p2 <= 65535 && p1 <= p2 )); then
      return 0
    fi
  fi
  return 1
}

# ------------------------------------------------------------------------------
# Modules
# ------------------------------------------------------------------------------

network_scan() {
  read -rp "Enter the IP range to scan (e.g., 192.168.1.0/24): " ip_range
  if ! validate_ip_or_domain "$ip_range"; then
    echo "Invalid IP or CIDR notation."
    return 1
  fi

  read -rp "Save output to file? (y/n): " save_opt
  if [[ "$save_opt" =~ ^[Yy]$ ]]; then
    read -rp "Enter output file name: " out_file
    nmap -p 1-65535 -sS -Pn --open "$ip_range" -oN "$out_file"
    echo "Results saved to '$out_file'."
  else
    nmap -p 1-65535 -sS -Pn --open "$ip_range"
  fi
}

port_scan() {
  read -rp "Enter the IP address to scan: " ip_address
  if ! validate_ip_or_domain "$ip_address"; then
    echo "Invalid IP address."
    return 1
  fi

  read -rp "Enter the port range to scan (e.g., 20-1024): " port_range
  if ! validate_port_range "$port_range"; then
    echo "Invalid port range. Use start-end within 1–65535."
    return 1
  fi

  read -rp "Save output to file? (y/n): " save_opt
  if [[ "$save_opt" =~ ^[Yy]$ ]]; then
    read -rp "Enter output file name: " out_file
    nmap -p "$port_range" "$ip_address" --open -oN "$out_file"
    echo "Results saved to '$out_file'."
  else
    nmap -p "$port_range" "$ip_address" --open
  fi
}

password_audit() {
  local password_file="passwords.txt"

  if [[ ! -s "$password_file" ]]; then
    echo "Password file '$password_file' not found or empty."
    return 1
  fi

  while IFS= read -r password; do
    [[ -z "$password" ]] && continue
    # cracklib-check outputs "password: OK" or reason
    local result
    result=$(cracklib-check <<< "$password" | awk -F': ' '{print $2}')
    printf "Password: '%s' → Strength: %s\n" "$password" "$result"
  done < "$password_file"
}

file_manipulation() {
  read -rp "Enter the file name (with extension): " file
  # Ensure no directory traversal
  local base
  base=$(basename -- "$file")

  echo "1) Encrypt file"
  echo "2) Decrypt file"
  read -rp "Choose an option [1-2]: " opt

  case "$opt" in
    1)
      if [[ -f "$base" ]]; then
        gpg -c -o "${base}.gpg" "$base"
        echo "Encrypted to ${base}.gpg"
      else
        echo "File '$base' not found."
      fi
      ;;
    2)
      if [[ -f "${base}.gpg" ]]; then
        gpg -d -o "$base" "${base}.gpg"
        echo "Decrypted to $base"
      else
        echo "Encrypted file '${base}.gpg' not found."
      fi
      ;;
    *)
      echo "Invalid selection."
      ;;
  esac
}

whois_lookup() {
  read -rp "Enter a domain or IP address: " target
  if validate_ip_or_domain "$target"; then
    whois "$target"
  else
    echo "Invalid input."
  fi
}

dns_lookup() {
  read -rp "Enter a domain name: " target
  if validate_ip_or_domain "$target"; then
    dig +short "$target"
  else
    echo "Invalid domain."
  fi
}

# ------------------------------------------------------------------------------
# Main Menu
# ------------------------------------------------------------------------------

main_menu() {
  while true; do
    banner
    cat <<-EOF
    1) Network scanning and discovery
    2) Port scanning
    3) Password auditing
    4) File encryption/decryption
    5) WHOIS lookup
    6) DNS lookup
    7) Exit
EOF
    read -rp "Choose an option [1-7]: " choice
    case "$choice" in
      1) network_scan ;;
      2) port_scan ;;
      3) password_audit ;;
      4) file_manipulation ;;
      5) whois_lookup ;;
      6) dns_lookup ;;
      7) echo "Exiting. Stay secure!"; exit 0 ;;
      *) echo "Invalid option; try again." ;;
    esac
    echo
  done
}

# Launch
main_menu