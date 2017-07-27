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
location="taylor"

datasets_android_taylor="gimbalwest_corrected_03222016_walk1 gimbalwest_corrected_03222016_walk2 gimbalwest_corrected_03212016_walk1"
for dir in $directories; do
	mkdir -p pose_output_exp/${dir}/${location}/

	for dataset in $datasets_android_taylor; do
		for interval in $intervals; do

			for count in 100 300 500; do
				#for error in 20.0 10.0 5.0 2.0 1.0; do
				for error in 10.0; do

					# bundle_file=${FRAMES_DIR}/bundler_output_ratioranked/${dir}/${location}/gimbalwest_03222016_walk1_${interval}/bundle.info
					# image_list_file=$FRAMES_DIR/images_input/${dir}/${location}/${dataset}/list_keys.txt
					# output_file=pose_output_exp/${dir}/${location}/loc_count${count}_error${error}_${dataset}_${interval}.txt
					# #echo $bundle_file

					# if [ "$dir" == "jpg360p" ]; then
   					# 	echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 640 -h 360 -c $count -e $error -o $output_file > /dev/null"
					# elif [ "$dir" == "jpg720p" ]; then
					# 	echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 1280 -h 720 -c $count -e $error -o $output_file > /dev/null"
					# elif [ "$dir" == "jpg1080p" ]; then
					# 	echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 1920 -h 1080 -c $count -e $error -o $output_file > /dev/null"
					# else
					# 	echo "Invalid/unknown directory"
					# fi				
					
					bundle_file=${FRAMES_DIR}/bundler_output_ratioranked/${dir}/${location}/gimbalwest_03222016_walk1_${interval}/bundle_mean.infowcam
					image_list_file=$FRAMES_DIR/images_input/${dir}/${location}/${dataset}/list_keys.txt
					output_file=pose_output_exp/${dir}/${location}/loc_mean_count${count}_error${error}_${dataset}_${interval}.txt
					#echo $bundle_file

					if [ "$dir" == "jpg360p" ]; then
   						echo "./localizer/build/bin/pose_estimator_mean -b $bundle_file -k $image_list_file -w 640 -h 360 -c $count -e $error -o $output_file > /dev/null"
					elif [ "$dir" == "jpg720p" ]; then
						echo "./localizer/build/bin/pose_estimator_mean -b $bundle_file -k $image_list_file -w 1280 -h 720 -c $count -e $error -o $output_file > /dev/null"
					elif [ "$dir" == "jpg1080p" ]; then
						echo "./localizer/build/bin/pose_estimator_mean -b $bundle_file -k $image_list_file -w 1920 -h 1080 -c $count -e $error -o $output_file > /dev/null"
					else
						echo "Invalid/unknown directory"
					fi				



					# #just point reduction
					# for reduction in 10 5 2; do
					# 	bundle_file=${FRAMES_DIR}/bundler_output_ratioranked/${dir}/${location}/gimbalwest_03222016_walk1_${interval}/bundle_gt${reduction}.info
					# 	image_list_file=$FRAMES_DIR/images_input/${dir}/${location}/${dataset}/list_keys.txt
					# 	output_file=pose_output_exp/${dir}/${location}/loc_bundlegt${reduction}_count${count}_error${error}_${dataset}_${interval}.txt


					# 	if [ "$dir" == "jpg360p" ]; then
   					# 		echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 640 -h 360 -c $count -e $error -o $output_file > /dev/null"
					# 	elif [ "$dir" == "jpg720p" ]; then
					# 		echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 1280 -h 720 -c $count -e $error -o $output_file > /dev/null"
					# 	elif [ "$dir" == "jpg1080p" ]; then
					# 		echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 1920 -h 1080 -c $count -e $error -o $output_file > /dev/null"
					# 	else
					# 		echo "Invalid/unknown directory"
					# 	fi				
					# done


					for reduction in 10 5 2; do
						bundle_file=${FRAMES_DIR}/bundler_output_ratioranked/${dir}/${location}/gimbalwest_03222016_walk1_${interval}/bundle_mean_gt${reduction}.infowcam
						image_list_file=$FRAMES_DIR/images_input/${dir}/${location}/${dataset}/list_keys.txt
						output_file=pose_output_exp/${dir}/${location}/loc_mean_bundlegt${reduction}_count${count}_error${error}_${dataset}_${interval}.txt


						if [ "$dir" == "jpg360p" ]; then
   							echo "./localizer/build/bin/pose_estimator_mean -b $bundle_file -k $image_list_file -w 640 -h 360 -c $count -e $error -o $output_file > /dev/null"
						elif [ "$dir" == "jpg720p" ]; then
							echo "./localizer/build/bin/pose_estimator_mean -b $bundle_file -k $image_list_file -w 1280 -h 720 -c $count -e $error -o $output_file > /dev/null"
						elif [ "$dir" == "jpg1080p" ]; then
							echo "./localizer/build/bin/pose_estimator_mean -b $bundle_file -k $image_list_file -w 1920 -h 1080 -c $count -e $error -o $output_file > /dev/null"
						else
							echo "Invalid/unknown directory"
						fi				
					done


				done
			done
		done
	done	
done
	


# #
# # android
# #
# location="sce"
# datasets_android_sce="gimbalsubway_03232015_walk1 gimbalsubway_03232015_walk2"
# for dir in $directories; do
# 	mkdir -p pose_output_exp/${dir}/${location}/

# 	for dataset in $datasets_android_sce; do
# 		for interval in $intervals; do
# 			for count in 100 300 500; do
# 				for error in 10.0; do

#  					bundle_file=${FRAMES_DIR}/bundler_output_ratioranked/${dir}/${location}/gimbalsubway_03232015_walk1_${interval}/bundle.info
#  					image_list_file=$FRAMES_DIR/images_input/${dir}/${location}/${dataset}/list_keys.txt
#  					output_file=pose_output_exp/${dir}/${location}/loc_count${count}_error${error}_${dataset}_${interval}.txt


# 					if [ "$dir" == "jpg360p" ]; then
#    						echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 640 -h 360 -c $count -e $error -o $output_file > /dev/null"
# 					elif [ "$dir" == "jpg720p" ]; then
# 						echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 1280 -h 720 -c $count -e $error -o $output_file > /dev/null"
# 					elif [ "$dir" == "jpg1080p" ]; then
# 						echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 1920 -h 1080 -c $count -e $error -o $output_file > /dev/null"
# 					else
# 						echo "Invalid/unknown directory"
# 					fi				



# 					# for reduction in 10 5 2; do
						
# 					# 	if [ "$dir" == "jpg360p" ]; then
#    					# 		echo "./localizer/build/bin/pose_estimator_exp -b bundler_output_ratioranked/${dir}/sce/gimbalsubway_03232015_walk1_${interval}/bundle_gt${reduction}.info -k images_input/${dir}/${dataset}/list_keys.txt -w 640 -h 360 -c $count -e $error -o pose_output_ratioranked/exp/${dir}/loc_bundlegt${reduction}_count${count}_error${error}_${dataset_filename}_${interval}.txt > /dev/null"
							
# 					# 	elif [ "$dir" == "jpg720p" ]; then
							
# 					# 		echo "./localizer/build/bin/pose_estimator_exp -b bundler_output_ratioranked/${dir}/sce/gimbalsubway_03232015_walk1_${interval}/bundle_gt${reduction}.info -k images_input/${dir}/${dataset}/list_keys.txt -w 1280 -h 720 -c $count -e $error -o pose_output_ratioranked/exp/${dir}/loc_bundlegt${reduction}_count${count}_error${error}_${dataset_filename}_${interval}.txt > /dev/null"
# 					# 	elif [ "$dir" == "jpg1080p" ]; then
							
# 					# 		echo "./localizer/build/bin/pose_estimator_exp -b bundler_output_ratioranked/${dir}/sce/gimbalsubway_03232015_walk1_${interval}/bundle_gt${reduction}.info -k images_input/${dir}/${dataset}/list_keys.txt -w 1920 -h 1080 -c $count -e $error -o pose_output_ratioranked/exp/${dir}/loc_bundlegt${reduction}_count${count}_error${error}_${dataset_filename}_${interval}.txt > /dev/null"
	
# 					# 	else
# 					# 		echo "Invalid/unknown directory"
# 					# 	fi				
			

					
# 				done
# 			done
# 		done
# 	done	
# done
	





# #
# # iphone
# #
# location="tayloriphone" 
# datasets_iphone="gimbal_i6_11202015_walk1 gimbal_i6_11202015_walk2"
# first_pole=14
# last_pole=17

# for dir in $directories; do
# 	mkdir -p pose_output_exp/${dir}/${location}/

# 	for dataset in $datasets_iphone; do
# 		for interval in $intervals; do
# 			for count in 100 300 500; do
# 				for error in 10.0; do
					
# 					first_frame=`cat $PROJECT_DIR/log_data/$location/$dataset/info_log_combined.txt | awk '$1==p {print $2}' p=$first_pole`
# 					last_frame=`cat $PROJECT_DIR/log_data/$location/$dataset/info_log_combined.txt | awk '$1==p {print $2}' p=$last_pole`


# 					#produce list.key file
# 					for i in `seq $first_frame $last_frame`;do 
# 						echo "${FRAMES_DIR}/frames_input/${dir}/$location/${dataset}/frame$i.key"
# 					done > /tmp/list_keys_${dir}_${location}_${dataset}_i${interval}_p${first_pole}_${last_pole}.txt

# 					bundle_file=${PROJECT_DIR}/bundler_output/${dir}/${location}/gimbal_i6_11202015_walk1_i10_p${first_pole}_${last_pole}/bundle.info
# 					image_list_file=/tmp/list_keys_${dir}_${location}_${dataset}_i${interval}_p${first_pole}_${last_pole}.txt
# 					output_file=pose_output_exp/${dir}/${location}/loc_count${count}_error${error}_${dataset}_i${interval}_p${first_pole}_${last_pole}.txt


					

# 					if [ "$dir" == "jpg360p" ]; then
# 						echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 640 -h 360 -c $count -e $error -o $output_file > /dev/null"
# 					elif [ "$dir" == "jpg720p" ]; then
# 						echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 1280 -h 720 -c $count -e $error -o $output_file > /dev/null"
# 					elif [ "$dir" == "jpg1080p" ]; then
# 						echo "./localizer/build/bin/pose_estimator_exp -b $bundle_file -k $image_list_file -w 1920 -h 1080 -c $count -e $error -o $output_file > /dev/null"
# 					else
# 						echo "Invalid/unknown directory"
# 					fi

						
# 					#echo "./localizer/build/bin/pose_estimator_exp -b bundler_output_ratioranked/${dir}/${location}/gimbal_i6_11202015_walk1_500_2500_${interval}/bundle.info -k frames_input/${dir}/${dataset}/list_keys.txt -w 1280 -h 720 -c $count -e $error -o pose_output_ratioranked/exp/${dir}/loc_count${count}_error${error}_${dataset_filename}_${interval}.txt > /dev/null"

					

# 					# for reduction in 10 5 2; do
						
# 					# 	if [ "$dir" == "jpg360p" ]; then
#    					# 		echo "./localizer/build/bin/pose_estimator_exp -b bundler_output_ratioranked/${dir}/${location}/gimbal_i6_11202015_walk1_500_2500_${interval}/bundle_gt${reduction}.info -k frames_input/${dir}/${dataset}/list_keys.txt -w 640 -h 360 -c $count -e $error -o pose_output_ratioranked/exp/${dir}/loc_bundlegt${reduction}_count${count}_error${error}_${dataset_filename}_${interval}.txt > /dev/null"
							
# 					# 	elif [ "$dir" == "jpg720p" ]; then
							
# 					# 		echo "./localizer/build/bin/pose_estimator_exp -b bundler_output_ratioranked/${dir}/${location}/gimbal_i6_11202015_walk1_500_2500_${interval}/bundle_gt${reduction}.info -k frames_input/${dir}/${dataset}/list_keys.txt -w 1280 -h 720 -c $count -e $error -o pose_output_ratioranked/exp/${dir}/loc_bundlegt${reduction}_count${count}_error${error}_${dataset_filename}_${interval}.txt > /dev/null"
# 					# 	elif [ "$dir" == "jpg1080p" ]; then
							
# 					# 		echo "./localizer/build/bin/pose_estimator_exp -b bundler_output_ratioranked/${dir}/${location}/gimbal_i6_11202015_walk1_500_2500_${interval}/bundle_gt${reduction}.info -k frames_input/${dir}/${dataset}/list_keys.txt -w 1920 -h 1080 -c $count -e $error -o pose_output_ratioranked/exp/${dir}/loc_bundlegt${reduction}_count${count}_error${error}_${dataset_filename}_${interval}.txt > /dev/null"
							
# 					# 	else
# 					# 		echo "Invalid/unknown directory"
# 					# 	fi				
						
						
# 					# done

# 				done
# 			done
# 		done	
# 	done
# done






