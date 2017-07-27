#!/bin/bash

#
# Taylor street logs are in ~/imgloc/logs. Getting some data here.
#

#location_frames="tayloriphone" # IMPORTANT: change this
#location_log="taylor_st" # IMPORTANT: change this
location_frames="lakeshore" # IMPORTANT: change this
location_log="lakeshore_dr" # IMPORTANT: change this



#datasets="gimbal_i6_11202015_walk1 gimbal_i6_11202015_walk2"
#datasets="chest_i6_11202015_walk1 chest_i6_11202015_walk2 chest_i6_110215_walk1 chest_i6_110215_walk2 chest_i6_111115_walk1 chest_i6_111115_walk2"
#datasets="chest_i6_11022015_walk1 chest_i6_11022015_walk2"
datasets="car_i6_11202015_drive1 car_i6_11202015_drive2" # IMPORTANT: change this

#
# get movie frames
#
for dataset in $datasets; do
	mkdir -p ~/visualloc/frames_input/jpg1080p/${location_frames}/${dataset}/
	rm ~/visualloc/frames_input/jpg1080p/${location_frames}/${dataset}/*

    # get frames for the video
	ffmpeg -i ~/imgloc/logs/${location_log}/${dataset}/video.MOV -vsync 0 ~/visualloc/frames_input/jpg1080p/${location_frames}/${dataset}/frame%d.jpg


    # rename the frame files to match the frame number in other log files
	echo "renaming files ..."
	frames_fullname=`ls ~/visualloc/frames_input/jpg1080p/${location_frames}/${dataset}`
	all_frames=`for f in $frames_fullname; do echo $f | sed 's/frame//g; s/.jpg//g'; done | sort -n`
	
	for frame in $all_frames; do
		frame_new=`echo $frame | awk '{print $1-1}'`
		#echo $frame $frame_new
		mv ~/visualloc/frames_input/jpg1080p/${location_frames}/${dataset}/frame${frame}.jpg ~/visualloc/frames_input/jpg1080p/${location_frames}/${dataset}/frame${frame_new}.jpg
	done
	
done


#
# resize images
#
#create dir (if missing) and clean up existing data
for dataset in $datasets; do
	mkdir -p ~/visualloc/frames_input/jpg720p/${location_frames}/$dataset/
	rm ~/visualloc/frames_input/jpg720p/${location_frames}/$dataset/*

	mkdir -p ~/visualloc/frames_input/jpg360p/${location_frames}/$dataset/
	rm ~/visualloc/frames_input/jpg360p/${location_frames}/$dataset/*
done

for dataset in $datasets; do
	for f in `ls ~/visualloc/frames_input/jpg1080p/${location_frames}/${dataset}/`; do
		echo "/usr/bin/convert ~/visualloc/frames_input/jpg1080p/${location_frames}/${dataset}/$f -resize 1280x720 ~/visualloc/frames_input/jpg720p/${location_frames}/$dataset/$f"
		echo "/usr/bin/convert ~/visualloc/frames_input/jpg1080p/${location_frames}/${dataset}/$f -resize 640x360 ~/visualloc/frames_input/jpg360p/${location_frames}/$dataset/$f"
	done
done | parallel

