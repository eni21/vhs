#!/bin/sh

set -e

ffmpeg -re \
    -fflags +genpts -stream_loop -1 \
    -i "input/file_example_MP4_1920.mp4" \
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
    -f flv "rtmp://127.0.0.1:1935/src/aaa"
