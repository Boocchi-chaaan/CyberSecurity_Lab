# music
music for mp3 to wav

Instalation

sudo apt-get install sox libsox-fmt-mp3

for use

sudo sox my-audio.mp3 -r 44100 -c 1 -b 16 -t wav my-converted-audio.wav
