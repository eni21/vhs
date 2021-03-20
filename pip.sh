#!/bin/bash
set -e

rm -rf output/picinpic/*
mkdir -p output/picinpic

# "[1]scale=iw/10:ih/10 [pip]; [0][pip] overlay=main_w-overlay_w-10:main_h-overlay_h-10" \
# "[1]scale=300:200 [pip]; [0][pip] overlay=main_w-overlay_w-10:main_h-overlay_h-10"

ffmpeg -y -i input/file_example_800.jpg -i input/file_example_MP4_1920.mp4 \
    -filter_complex \
    "[1]scale=250:150 [pip]; [0][pip] overlay=10:10" \
    -c:a aac -c:v libx264 \
    -b:v 1000k \
    -r 24 \
    output/pip/aaa.mp4
