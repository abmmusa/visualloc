#!/bin/bash

#
# android
#

PROJECT_DIR="/home/musa/research/visloc"
IMG_DIR="/home/musa/research/imgloc"
FRAMES_DIR="/home/musa/research/visualloc"


TOPDIR="bundler_output_ratioranked"
directories="jpg720p"
intervals="20 10"


#
# iphone
#




datasets="gimbal_i6_11202015_walk1_600_900 gimbal_i6_11202015_walk2_600_900 gimbal_i6_10212015_walk1_600_1000 gimbal_i6_10212015_walk2_600_1000"
comp_types="constrained ratiotested"

#for subdivision in 16 8 4 2 1; do
for subdivision in 16 8 4 2; do
	#for tracking in 10 20 50 100; do
	for tracking in 10 50 100; do
		for dataset in $datasets; do
			for comp_type in $comp_types; do
				

				echo "ffmpeg -r 8 -start_number 600 -i vis_tracking_new/vis_suvdiv${subdivision}_track${tracking}_${dataset}_${comp_type}/frame%d.jpg -r 24 -pix_fmt yuv420p videos/vis_tracking_new/vis_suvdiv${subdivision}_track${tracking}_${dataset}_${comp_type}.mpeg"

				
			done
		done
	done
done






