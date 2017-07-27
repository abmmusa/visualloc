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
location="tayloriphone" 
datasets_iphone="gimbal_i6_11202015_walk1 gimbal_i6_11202015_walk2"
first_pole=14
last_pole=17

for dir in $directories; do
	mkdir -p pose_output_subdivided_wqueue_kalman/${dir}/${location}/

	for dataset in $datasets_iphone; do
		for interval in $intervals; do
			#for subdivision in 16 8 4 2 1; do
			for subdivision in 8 4; do
				#for tracking in 10 20 50 100; do
				for tracking in 10 100; do
					
					mkdir -p reconstruction_data/vis_suvdiv${subdivision}_track${tracking}_${dataset}_i${interval}_p${first_pole}_${last_pole}
					
					first_frame=`cat $PROJECT_DIR/log_data/$location/$dataset/info_log_combined.txt | awk '$1==p {print $2}' p=$first_pole`
					last_frame=`cat $PROJECT_DIR/log_data/$location/$dataset/info_log_combined.txt | awk '$1==p {print $2}' p=$last_pole`
					

					#produce list.key file TODO: move away from /tmp files as it might conflict with other process running at the same time
					for i in `seq $first_frame $last_frame`;do 
						echo "${FRAMES_DIR}/frames_input/${dir}/$location/${dataset}/frame$i.key"
					done > /tmp/list_keys_${dir}_${location}_${dataset}_i${interval}_p${first_pole}_${last_pole}.txt
					
					bundle_file=${PROJECT_DIR}/bundler_output/${dir}/${location}/gimbal_i6_11202015_walk1_i10_p${first_pole}_${last_pole}/bundle.infowcam
					image_list_file=/tmp/list_keys_${dir}_${location}_${dataset}_i${interval}_p${first_pole}_${last_pole}.txt
					output_file=pose_output_subdivided_wqueue_kalman/${dir}/${location}/loc_suvdiv${subdivision}_track${tracking}_${dataset}_i${interval}_p${first_pole}_${last_pole}.txt
					vis_dir=reconstruction_data/vis_suvdiv${subdivision}_track${tracking}_${dataset}_i${interval}_p${first_pole}_${last_pole}
					

					if [ "$dir" == "jpg360p" ]; then
						echo "./localizer/build/bin/pose_estimator_subdivided_wqueue_kalman -b $bundle_file -k $image_list_file -w 640 -h 360 -s $subdivision -t $tracking -o $output_file -v $vis_dir > /dev/null"
					elif [ "$dir" == "jpg720p" ]; then
						echo "./localizer/build/bin/pose_estimator_subdivided_wqueue_kalman -b $bundle_file -k $image_list_file -w 1280 -h 720 -s $subdivision -t $tracking -o $output_file -v $vis_dir > /dev/null"
					elif [ "$dir" == "jpg1080p" ]; then
						echo "./localizer/build/bin/pose_estimator_subdivided_wqueue_kalman -b $bundle_file -k $image_list_file -w 1920 -h 1080 -s $subdivision -t $tracking -o $output_file -v $vis_dir > /dev/null"
					else
						echo "Invalid/unknown directory"
					fi

				done
			done
		done	
	done
done






