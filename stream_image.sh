#!/bin/sh

set -e

ffmpeg -re \
    -loop 1 \
    -i "input/file_example_800.jpg" \
    -c:v libx264 \
    -preset veryfast \
    -maxrate 3000k \
    -bufsize 6000k \
    -pix_fmt yuv420p \
    -g 5 \
    -c:a aac \
    -b:a 160k \
    -ac 2 \
    -ar 44100 \
    -f flv "rtmp://127.0.0.1:1935/src/aaa"
