#!/bin/bash

read -p "chanel to use (for example 90.1): " chan

sox tsoileto.mp3 -r 44100 -c 1 -b 16 -t wav - | sudo ./fm_transmitter -f $chan -
