#!/bin/bash

sox tsoileto.mp3 -r 44100 -c 1 -b 16 -t wav - | sudo ./fm_transmitter -f 90.1 -
