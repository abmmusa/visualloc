#!/bin/bash

FRAMES_DIR="/home/musa/research/visualloc"
TOPDIR="frames_input"

#location="tayloriphone"
location="lakeshore"
#datasets="chest_i6_11202015_walk1 chest_i6_11202015_walk2 chest_i6_11112015_walk1 chest_i6_11112015_walk2" # chest_i6_110215_walk1 chest_i6_1102115_walk2"
#datasets="gimbal_i6_10212015_walk1 gimbal_i6_10212015_walk2"
datasets="car_i6_11202015_drive1 car_i6_11202015_drive2" # IMPORTANT: change this


#for dir in "jpg360p" "jpg720p" "jpg1080p"; do
for dir in "jpg720p"; do
	for dataset in $datasets; do
		for f in `ls $FRAMES_DIR/$TOPDIR/$dir/${location}/$dataset/ | grep jpg | sed 's/.jpg//g'`; do    
			echo "/usr/bin/mogrify -format pgm $FRAMES_DIR/$TOPDIR/$dir/${location}/$dataset/$f.jpg"
		done
	done
done | parallel


#for dir in "jpg360p" "jpg720p" "jpg1080p"; do
for dir in "jpg720p"; do
	for dataset in $datasets; do
		for f in `ls $FRAMES_DIR/$TOPDIR/$dir/${location}/$dataset/ | grep jpg | sed 's/.jpg//g'`; do    
			echo "$FRAMES_DIR/thirdparty/lowe_sift/sift < $FRAMES_DIR/$TOPDIR/$dir/${location}/$dataset/$f.pgm > $FRAMES_DIR/$TOPDIR/$dir/${location}/$dataset/$f.key"
		done
	done
done | parallel


#for dir in "jpg360p" "jpg720p" "jpg1080p"; do
for dir in "jpg720p"; do
	for dataset in $datasets; do
		for f in `ls $FRAMES_DIR/$TOPDIR/$dir/${location}/$dataset/ | grep jpg | sed 's/.jpg//g'`; do    
			echo "rm $FRAMES_DIR/$TOPDIR/$dir/${location}/$dataset/$f.pgm"
		done
	done
done | parallel





