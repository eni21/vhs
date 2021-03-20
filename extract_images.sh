#!/bin/bash

set -e

rm -rf output/img/*
mkdir -p "output/img"

## get 5 images from all length
len=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "input/file_example_MP4_1920.mp4")
interval=$(echo "$len / 5 " | bc)
fps="1/$interval"
ffmpeg -i "input/file_example_MP4_1920.mp4" -s 240x135 -vf fps=$fps "output/img/aaa%03d.png"

## webp
len=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "input/file_example_MP4_1920.mp4")
middle=$(echo "$len / 2 " | bc)
ffmpeg -i "input/file_example_MP4_1920.mp4" -ss $middle"s" -t "5s" -vcodec libwebp -s 240x135 -loop 1000 "output/img/aaa.webp"
