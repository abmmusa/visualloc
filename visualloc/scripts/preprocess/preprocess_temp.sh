#!/bin/bash

#
# Taylor street logs are in ~/imgloc/logs. Getting some data here.
#


#datasets="gimbal_i6_11202015_walk1 gimbal_i6_11202015_walk2"
datasets="chest_i6_11022015_walk1 chest_i6_11022015_walk2 chest_i6_11112015_walk1 chest_i6_11112015_walk2"


#
# get movie frames
#
for dataset in $datasets; do
	mkdir -p ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/
	rm ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/*

    # get frames for the video
	ffmpeg -i ~/imgloc/logs/taylor_st/${dataset}/video.MOV -vsync 0 ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/frame%d.jpg


    # rename the frame files to match the frame number in other log files
	echo "renaming files ..."
	frames_fullname=`ls ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}`
	all_frames=`for f in $frames_fullname; do echo $f | sed 's/frame//g; s/.jpg//g'; done | sort -n`
	
	for frame in $all_frames; do
		frame_new=`echo $frame | awk '{print $1-1}'`
		#echo $frame $frame_new
		mv ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/frame${frame}.jpg ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/frame${frame_new}.jpg
	done
	
done


#
# resize images
#
#create dir (if missing) and clean up existing data
for dataset in $datasets; do
	mkdir -p ~/visualloc/frames_input/jpg720p/tayloriphone/$dataset/
	rm ~/visualloc/frames_input/jpg720p/tayloriphone/$dataset/*

	mkdir -p ~/visualloc/frames_input/jpg360p/tayloriphone/$dataset/
	rm ~/visualloc/frames_input/jpg360p/tayloriphone/$dataset/*
done

for dataset in $datasets; do
	for f in `ls ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/`; do
		echo "/usr/bin/convert ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/$f -resize 1280x720 ~/visualloc/frames_input/jpg720p/tayloriphone/$dataset/$f"
		echo "/usr/bin/convert ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/$f -resize 640x360 ~/visualloc/frames_input/jpg360p/tayloriphone/$dataset/$f"
	done
done | parallel

