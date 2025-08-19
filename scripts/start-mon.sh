#!/bin/bash

clear

echo "What do you want to do? also sellect WiFi interdace"
iwconfig 2>/dev/null | grep -o "^[a-zA-Z0-9_-]*" | grep "^wlan"
read -p "[?] Enter WiFi interface: " int
select action in "Start Monitor Mode" "Stop Monitor Mode" "Exit"; do
     case $action in
        "Start Monitor Mode")
            airmon-ng check kill
	    airmon-ng start $int
            echo "[+] $int in monitor mode"
            break
            ;;
        "Stop Monitor Mode")
	    airmon-ng stop $int
	    systemctl start wpa_supplicant
	    systemctl start NetworkManager
            echo "[+] Monitor Mode Stoped"
            break
            ;;
        "Exit")
            echo "[+] Exiting..."
            exit 0
            ;;
        *)
            echo "[?] Invalid option."
            ;;
    esac
done
