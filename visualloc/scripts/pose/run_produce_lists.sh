#!/bin/bash

PROJECT_DIR="/home/musa/research/visloc"
IMG_DIR="/home/musa/research/imgloc"
FRAMES_DIR="/home/musa/research/visualloc"

###########################################################################
# list for test images
###########################################################################


# # taylor test images
# for resolution in "jpg1080p" "jpg720p" "jpg360p"; do
# 	for dataset in "taylor/gimbalwest_03212016_walk1" "taylor/gimbalwest_03222016_walk1" "taylor/gimbalwest_03222016_walk2"; do
# 		total_files=`ls images_input/${resolution}/${dataset}/*.jpg | wc -l`
# 		upper_bound=`echo $total_files | awk '{print $1-1}'`
# 		echo $dataset $total_files $upper_bound
			
# 		for i in `seq 0 $upper_bound`; do
# 			echo "./images_input/${resolution}/${dataset}/frame$i.key"
# 		done > images_input/${resolution}/${dataset}/list_keys.txt

# 	done
# done


# # sce test images
# for resolution in "jpg1080p" "jpg720p" "jpg360p"; do
# 	for dataset in "sce/gimbalsubway_03232015_walk1" "sce/gimbalsubway_03232015_walk2"; do
# 		total_files=`ls images_input/${resolution}/${dataset}/*.jpg | wc -l`
# 		upper_bound=`echo $total_files | awk '{print $1-1}'`
# 		echo $dataset $total_files $upper_bound
			
# 		for i in `seq 0 $upper_bound`; do
# 			echo "./images_input/${resolution}/${dataset}/frame$i.key"
# 		done > images_input/${resolution}/${dataset}/list_keys.txt

# 	done
# done

#
#973.474509
#





#
# android
#

directories="jpg720p"
intervals="20 10"

datasets_android="taylor/gimbalwest_corrected_03212016_walk1 taylor/gimbalwest_corrected_03222016_walk1 taylor/gimbalwest_corrected_03222016_walk2"

for dir in $directories; do
	for dataset in $datasets_android; do
		frame_nos=`ls ${FRAMES_DIR}/images_input/${dir}/${dataset} | grep jpg | sed 's/frame//g; s/.jpg//g' | sort -n`

		for i in $frame_nos; do
			echo "${FRAMES_DIR}/images_input/${dir}/${dataset}/frame$i.key"
		done > ${FRAMES_DIR}/images_input/${dir}/${dataset}/list_keys.txt

	done
done


datasets_android_sce="sce/gimbalsubway_03232015_walk1 sce/gimbalsubway_03232015_walk2"

for dir in $directories; do
	for dataset in $datasets_android_sce; do
		frame_nos=`ls ${FRAMES_DIR}/images_input/${dir}/${dataset} | grep jpg | sed 's/frame//g; s/.jpg//g' | sort -n`

		for i in $frame_nos; do
			echo "${FRAMES_DIR}/images_input/${dir}/${dataset}/frame$i.key"
		done > ${FRAMES_DIR}/images_input/${dir}/${dataset}/list_keys.txt

	done
done



# #
# # iphone
# #
# #only difference here is that the path starts with frames_input rather than images_input
# datasets_iphone="tayloriphone/gimbal_i6_11202015_walk1_500_2500 tayloriphone/gimbal_i6_11202015_walk2_500_2500"

# for dir in $directories; do
# 	for dataset in $datasets_iphone; do
# 		lower_bound=`ls frames_input/${dir}/${dataset}/*.jpg | awk -F/ '{print $NF}' | sed 's/frame//g; s/.jpg//g' | sort -n | head -1`
# 		upper_bound=`ls frames_input/${dir}/${dataset}/*.jpg | awk -F/ '{print $NF}' | sed 's/frame//g; s/.jpg//g' | sort -n | tail -1`
		
# 		for i in `seq $lower_bound $interval $upper_bound`; do				
# 			echo "./frames_input/${dir}/${dataset}/frame$i.key"
# 		done > frames_input/${dir}/${dataset}/list_keys.txt

# 	done
# done






