#!/bin/bash

clear

echo "What do you want to do?"

select action in "Fluxion" "Wifite2" "Exit"; do
    case $action in
        "Fluxion")
            airmon-ng check kill
	    airmon-ng start wlan0
	    echo "Starting Fluxion"
	    $PWD/wlan/fluxion/fluxion.sh -i
            break
            ;;
        "Wifite2")
	    python $PWD/wlan/wifite2/Wifite.py
            break
            ;;
        "Exit")
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done
