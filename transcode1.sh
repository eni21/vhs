#!/bin/sh

set -e

DIR=`pwd`
NAME="file_example"
SOURCE_FILENAME="input/file_example_MP4_1920.mp4"

# clear output
rm -rf output/*

# create mp4 directory
mkdir -p "$DIR/output/mp4/$NAME/240p"
mkdir -p "$DIR/output/mp4/$NAME/360p"
mkdir -p "$DIR/output/mp4/$NAME/480p"

# create hls directory
mkdir -p "$DIR/output/hls/$NAME/240p"
mkdir -p "$DIR/output/hls/$NAME/360p"
mkdir -p "$DIR/output/hls/$NAME/480p"

# rescale
ffmpeg -i "$SOURCE_FILENAME" -vf scale=426:240 "$DIR/output/mp4/$NAME/240p/$NAME.mp4"
ffmpeg -i "$SOURCE_FILENAME" -vf scale=640:360 "$DIR/output/mp4/$NAME/360p/$NAME.mp4"
ffmpeg -i "$SOURCE_FILENAME" -vf scale=854:480 "$DIR/output/mp4/$NAME/480p/$NAME.mp4"

# convert
ffmpeg -i "$DIR/output/mp4/$NAME/240p/$NAME.mp4" \
    -codec: copy \
    -start_number 0 \
    -hls_time 10 \
    -hls_list_size 0 \
    -var_stream_map "v:0,a:0" \
    -master_pl_name "master.m3u8" \
    -f hls "$DIR/output/hls/$NAME/240p/$NAME.m3u8"
ffmpeg -i "output/mp4/$NAME/360p/$NAME.mp4" \
    -codec: copy \
    -start_number 0 \
    -hls_time 10 \
    -hls_list_size 0 \
    -var_stream_map "v:0,a:0" \
    -master_pl_name "master.m3u8" \
    -f hls "output/hls/$NAME/360p/$NAME.m3u8"
ffmpeg -i "output/mp4/$NAME/480p/$NAME.mp4" \
    -codec: copy \
    -start_number 0 \
    -hls_time 10 \
    -hls_list_size 0 \
    -var_stream_map "v:0,a:0" \
    -master_pl_name "master.m3u8" \
    -f hls "output/hls/$NAME/480p/$NAME.m3u8"

# compile master playlist
echo "#EXTM3U" >> "$DIR/output/hls/$NAME/master.m3u8"
echo "#EXT-X-VERSION:3" >> "$DIR/output/hls/$NAME/master.m3u8"
sed -n '3p' < "$DIR/output/hls/$NAME/240p/master.m3u8" >> "$DIR/output/hls/$NAME/master.m3u8"
echo "240p/$NAME.m3u8" >> "$DIR/output/hls/$NAME/master.m3u8"
sed -n '3p' < "$DIR/output/hls/$NAME/360p/master.m3u8" >> "$DIR/output/hls/$NAME/master.m3u8"
echo "360p/$NAME.m3u8" >> "$DIR/output/hls/$NAME/master.m3u8"
sed -n '3p' < "$DIR/output/hls/$NAME/480p/master.m3u8" >> "$DIR/output/hls/$NAME/master.m3u8"
echo "480p/$NAME.m3u8" >> "$DIR/output/hls/$NAME/master.m3u8"

# remove tmp playlists
rm -f "$DIR/output/hls/$NAME/240p/master.m3u8"
rm -f "$DIR/output/hls/$NAME/360p/master.m3u8"
rm -f "$DIR/output/hls/$NAME/480p/master.m3u8"
