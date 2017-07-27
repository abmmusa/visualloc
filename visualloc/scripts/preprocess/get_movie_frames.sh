#!/bin/bash

#
# Taylor street logs are in ~/imgloc/logs. Getting some data here.
#

datasets="gimbal_i6_11202015_walk1 gimbal_i6_11202015_walk2"


for dataset in $datasets; do
	mkdir ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/
    # get frames for the video
	ffmpeg -i ~/imgloc/logs/taylor_st/${dataset}/video.MOV -vsync 0 ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/frame%d.jpg


    # rename the frame files to match the frame number in other log files
	echo "renaming files ..."
	frames_fullname=`ls ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}`
	all_frames=`for f in $frames_fullname; do echo $f | sed 's/frame//g; s/.jpg//g'; done | sort -n`
	
	for frame in $all_frames; do
		frame_new=`echo $frame | awk '{print $1-1}'`
		#echo $frame $frame_new
		mv ~/visualoc/frames_input/jpg1080p/tayloriphone/${dataset}/frame${frame}.jpg ~/visualloc/frames_input/jpg1080p/tayloriphone/${dataset}/frame${frame_new}.jpg
	done
	
done
