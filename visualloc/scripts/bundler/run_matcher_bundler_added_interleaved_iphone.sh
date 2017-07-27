#!/bin/bash

PROJECT_DIR="/home/musa/research/visloc"
IMG_DIR="/home/musa/research/imgloc"
FRAMES_DIR="/home/musa/research/visualloc"
BUNDLER_DIR=~/visualloc/"/thirdparty/bundler_sfm/bin/"

BUNDLE2INFO=~/visualloc"/localizer/build/bin/Bundle2Info"
MATCHER=~/visualloc"/localizer/build/bin/flann_matcher_reduced_allmatch"
CAMADJUSTER=~/visualloc"/localizer/build/bin/BundleAdjustCams"


TOPDIR="bundler_added_output_interleaved" #IMPORTANT, change this appropriately
directories="jpg720p"
location="tayloriphone"

datasets=("gimbal_i6_11202015_walk1" "gimbal_i6_11202015_walk2")

#intervals="20 10 5"
intervals="20"
poles=(0 20)


pole_count=${#poles[@]}
loop_count=`echo $pole_count | awk '{print $1-1}'`



#
# copy stuff from ref dir and produce list_to_add.txt
#
for dir in $directories; do
	for interval in $intervals; do
		for dataset_ref in ${datasets[@]}; do
			for dataset_add in ${datasets[@]}; do
				if [ "$dataset_ref" != "$dataset_add" ]; then
					for p in `seq 1 $loop_count`; do
						prev=`echo $p | awk '{print $1-1}'`
						first_pole=${poles[$prev]}
						last_pole=${poles[$p]}
						first_frame=`cat $PROJECT_DIR/log_data/$location/${dataset_add}/info_log_combined.txt | awk '$1==p {print $2}' p=$first_pole`
						last_frame=`cat $PROJECT_DIR/log_data/$location/${dataset_add}/info_log_combined.txt | awk '$1==p {print $2}' p=$last_pole`
					
						path=${TOPDIR}/${dir}/$location/${dataset_ref}_${dataset_add}_i${interval}_p${first_pole}_${last_pole}

						mkdir -p ${path}
						mkdir -p ${path}/bundle
					
						echo $path $first_pole $last_pole $first_frame $last_frame
					
					    #copy relevent stuff from ref dataset
						cp bundler_output_interleaved/${dir}/$location/${dataset_ref}_i${interval}_p${first_pole}_${last_pole}/list.txt ${path}/
						cp bundler_output_interleaved/${dir}/$location/${dataset_ref}_i${interval}_p${first_pole}_${last_pole}/bundle/bundle.out ${path}/bundle/
					
						cp scripts/config_files_scripts/options_to_add.txt ${path}/

	   				    #produce list_to_add.txt
						for i in `seq $first_frame $last_frame`; do 
							if [ "$dir" == "jpg360p" ]; then
								echo "${FRAMES_DIR}/frames_input/${dir}/$location/${dataset_add}/frame$i.jpg 0 553.573003"
							elif [ "$dir" == "jpg720p" ]; then
								echo "${FRAMES_DIR}/frames_input/${dir}/$location/${dataset_add}/frame$i.jpg 0 1108.211915"
							elif [ "$dir" == "jpg1080p" ]; then
								echo "${FRAMES_DIR}/frames_input/${dir}/$location/${dataset_add}/frame$i.jpg 0 1661.576232"
							else
								echo "Invalid/unknown directory"
							fi
						
						done > ${path}/list_to_add.txt
					done
				fi
			done
		done
	done
done


#
# run bundler jobs
#
for dir in $directories; do
	for interval in $interval; do
		for dataset_ref in ${datasets[@]}; do
			for dataset_add in ${datasets[@]}; do
				if [ "$dataset_ref" != "$dataset_add" ]; then
					for p in `seq 1 $loop_count`; do
						prev=`echo $p | awk '{print $1-1}'`
						first_pole=${poles[$prev]}
						last_pole=${poles[$p]}
						first_frame=`cat $PROJECT_DIR/log_data/$location/${dataset_add}/info_log_combined.txt | awk '$1==p {print $2}' p=$first_pole`
						last_frame=`cat $PROJECT_DIR/log_data/$location/${dataset_add}/info_log_combined.txt | awk '$1==p {print $2}' p=$last_pole`
					
						path=${TOPDIR}/${dir}/$location/${dataset_ref}_${dataset_add}_i${interval}_p${first_pole}_${last_pole}

						original_dir=`pwd`
			
						
						cd $path

						rm bundle.added.out list.added.txt bundle.added.log
				
						if [ "$dir" == "jpg360p" ]; then
							$BUNDLER_DIR/bundler list.txt --add_images list_to_add.txt --bundle bundle/bundle.out --options_file options_to_add.txt --init_focal_length 553.573003 --fixed_focal_length > bundle.added.log &
						elif [ "$dir" == "jpg720p" ]; then
							$BUNDLER_DIR/bundler list.txt --add_images list_to_add.txt --bundle bundle/bundle.out --options_file options_to_add.txt --init_focal_length 1108.21191596 --fixed_focal_length > bundle.added.log &
						elif [ "$dir" == "jpg1080p" ]; then
							$BUNDLER_DIR/bundler list.txt --add_images list_to_add.txt --bundle bundle/bundle.out --options_file options_to_add.txt --init_focal_length 1661.576232 --fixed_focal_length > bundle.added.log &
						else
							echo "Invalid/unknown directory"
						fi
						
						cd $original_dir
						
	
					done
				fi
			done
		done
	done
done

wait


for dir in $directories; do
	for interval in $interval; do
		for dataset_ref in ${datasets[@]}; do
			for dataset_add in ${datasets[@]}; do
				if [ "$dataset_ref" != "$dataset_add" ]; then
					for p in `seq 1 $loop_count`; do
						prev=`echo $p | awk '{print $1-1}'`
						first_pole=${poles[$prev]}
						last_pole=${poles[$p]}
						first_frame=`cat $PROJECT_DIR/log_data/$location/${dataset_add}/info_log_combined.txt | awk '$1==p {print $2}' p=$first_pole`
						last_frame=`cat $PROJECT_DIR/log_data/$location/${dataset_add}/info_log_combined.txt | awk '$1==p {print $2}' p=$last_pole`
					
						path=${TOPDIR}/${dir}/$location/${dataset_ref}_${dataset_add}_i${interval}_p${first_pole}_${last_pole}

						original_dir=`pwd`
						
						
						cd $path

				        # IMPORTANT: -m flag for mean of all features, -f=1 for including cams
						$BUNDLE2INFO -b bundle/bundle.out -l list.txt -o bundle.infowcam -f 1 &
						$BUNDLE2INFO -b bundle.added.out -l list.added.txt -o bundle.added.infowcam -f 1 &

						cd $original_dir
	
					done
				fi
			done
		done
	done
done

wait

for dir in $directories; do
	for interval in $interval; do
		for dataset_ref in ${datasets[@]}; do
			for dataset_add in ${datasets[@]}; do
				if [ "$dataset_ref" != "$dataset_add" ]; then
					for p in `seq 1 $loop_count`; do
						prev=`echo $p | awk '{print $1-1}'`
						first_pole=${poles[$prev]}
						last_pole=${poles[$p]}
						first_frame=`cat $PROJECT_DIR/log_data/$location/${dataset_add}/info_log_combined.txt | awk '$1==p {print $2}' p=$first_pole`
						last_frame=`cat $PROJECT_DIR/log_data/$location/${dataset_add}/info_log_combined.txt | awk '$1==p {print $2}' p=$last_pole`
					
						path=${TOPDIR}/${dir}/$location/${dataset_ref}_${dataset_add}_i${interval}_p${first_pole}_${last_pole}
						echo $path

						original_dir=`pwd`
						
						distance=`scripts/bundler/util/get_poles_distance.sh $first_pole $last_pole`
						echo $distance

						cd $path

						#TODO: get the pole distances
						$CAMADJUSTER -b bundle.infowcam -d $distance -o cams_adjusted.txt
						$CAMADJUSTER -b bundle.added.infowcam -d $distance -o cams_adjusted.added.txt

						cd $original_dir
						
					done
				fi
			done
		done
	done
done


echo "all bundler jobs done!"