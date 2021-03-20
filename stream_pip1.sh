#!/bin/bash
set -e

#-i "input/sv1mb.mp4" \

ffmpeg -re \
    -fflags +genpts -stream_loop -1 \
    -i "input/sv2.mp4" \
    -c:v libx264 \
    -preset veryfast \
    -maxrate 3000k \
    -bufsize 6000k \
    -pix_fmt yuv420p \
    -g 50 \
    -c:a aac \
    -b:a 160k \
    -ac 2 \
    -ar 44100 \
    -flvflags no_duration_filesize \
    -f flv "rtmp://127.0.0.1:1935/pip1/pip"

# ffmpeg -re \
#     -loop 1 \
#     -i "input/file_example_800.jpg" \
#     -c:v libx264 \
#     -preset veryfast \
#     -maxrate 3000k \
#     -bufsize 6000k \
#     -pix_fmt yuv420p \
#     -g 50 \
#     -c:a aac \
#     -b:a 160k \
#     -ac 2 \
#     -ar 44100 \
#     -f flv "rtmp://127.0.0.1:1935/pip/pip"
