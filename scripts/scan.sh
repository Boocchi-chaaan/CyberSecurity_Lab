#!/bin/bash

clear

iface=$(iwconfig 2>/dev/null | grep "mon" | awk '{print $1}' | head -n1)

if [[ -z "$iface" ]]; then
    echo "[-] No monitor mode interface found (ending with 'mon')."
    exit 1
fi

clear

echo "[+] Found monitor mode interface: $iface"

echo "[*] Starting WiFi scan with $iface (press CTRL+C when done)..."
airodump-ng "$iface"
