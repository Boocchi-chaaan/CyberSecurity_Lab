#!/bin/bash

clear

# starts script
echo "What do you want to do?"

select action in "Start WiFi deauther script" "Start Fluxion" "Start Camera" "Anonymous" "Try FM Transmitter" "Try Bluetooth DOS Attack"  "Exit"; do
    case $action in
        "Start WiFi deauther script")
	    $PWD/scripts/start-mon.sh
	    $PWD/scripts/scan.sh
	    $PWD/scripts/attack.sh
            break
            ;;
        "Start Fluxion")
            /$PWD/wlan/fluxion/fluxion.sh -i
            break
            ;;
	"Start Camera")
            cd $PWD/scripts
	    ./start-capture.sh
            echo "Camera Starting..."
            break
            ;;
        "Try Bluetooth DOS Attack")
            cd $PWD/bt/DOS-Atack
	    python3 start.py
            echo "Done"
            break
            ;;
        "Try FM Transmitter")
            cd $PWD/fm_transmitter
	    ./start.sh
            echo "Done"
            break
            ;;
        "Anonymous")
            $PWD/scripts/anon.sh
            echo "Done"
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


