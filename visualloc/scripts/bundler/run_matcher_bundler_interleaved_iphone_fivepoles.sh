#!/bin/bash

MAX_FRAMES=300

PROJECT_DIR="/home/musa/research/visloc"
IMG_DIR="/home/musa/research/imgloc"
FRAMES_DIR="/home/musa/research/visualloc"

BUNDLER_DIR=~/visualloc/"/thirdparty/bundler_sfm/bin/"
MATCHER=~/visualloc"/localizer/build/bin/flann_matcher_reduced_allmatch"

BUNDLE2INFO=/home/musa/visualloc/localizer/build/bin/Bundle2Info
#CAMADJUSTER="/home/musa/research/visualloc/localizer/build/bin/BundleAdjustCams"


TOPDIR="bundler_output_interleaved"
directories="jpg720p"
location="tayloriphone"


#datasets="gimbal_i6_11202015_walk1 gimbal_i6_11202015_walk2 gimbal_i6_10212015_walk2 gimbal_i6_10212015_walk2"
#datasets="chest_i6_11202015_walk1 chest_i6_11202015_walk2 chest_i6_11112015_walk1 chest_i6_11112015_walk2"
datasets="gimbal_i6_11202015_walk1 gimbal_i6_11202015_walk2 gimbal_i6_10212015_walk2 gimbal_i6_10212015_walk2 chest_i6_11202015_walk1 chest_i6_11202015_walk2 chest_i6_11112015_walk1 chest_i6_11112015_walk2"

intervals="20 10 5"
#intervals="20 10"
#intervals="5"
#poles=(0 5 10 15)
#poles=(20 25 30 35)
poles=(15 19)

pole_count=${#poles[@]}
loop_count=`echo $pole_count | awk '{print $1-1}'`

			   
#
# produce list.txt list_keys.txt
#
for dir in $directories; do
	for dataset in $datasets; do
		for interval in $intervals; do
			for p in `seq 1 $loop_count`; do
				prev=`echo $p | awk '{print $1-1}'`
				first_pole=${poles[$prev]}
				last_pole=${poles[$p]}
				first_frame=`cat $PROJECT_DIR/log_data/$location/$dataset/info_log_combined.txt | awk '$1==p {print $2}' p=$first_pole`
				last_frame=`cat $PROJECT_DIR/log_data/$location/$dataset/info_log_combined.txt | awk '$1==p {print $2}' p=$last_pole`
				
				mkdir -p ${TOPDIR}/${dir}/$location/${dataset}_i${interval}_p${first_pole}_${last_pole}/
				
				echo $dataset $first_pole $last_pole $first_frame $last_frame
				
				for i in `seq $first_frame $interval $last_frame`; do 
						
					if [ "$dir" == "jpg360p" ]; then
						echo "${FRAMES_DIR}/frames_input/${dir}/$location/${dataset}/frame$i.jpg 0 553.573003"
					elif [ "$dir" == "jpg720p" ]; then
						echo "${FRAMES_DIR}/frames_input/${dir}/$location/${dataset}/frame$i.jpg 0 1108.211915"
					elif [ "$dir" == "jpg1080p" ]; then
						echo "${FRAMES_DIR}/frames_input/${dir}/$location/${dataset}/frame$i.jpg 0 1661.576232"
					else
						echo "Invalid/unknown directory"
					fi

				done > ${TOPDIR}/${dir}/$location/${dataset}_i${interval}_p${first_pole}_${last_pole}/list.txt

			done
		done
	done
done

for dir in $directories; do
	for dataset in $datasets; do
		for interval in $intervals; do
			for p in `seq 1 $loop_count`; do

				prev=`echo $p | awk '{print $1-1}'`
				first_pole=${poles[$prev]}
				last_pole=${poles[$p]}

				cat ${TOPDIR}/${dir}/$location/${dataset}_i${interval}_p${first_pole}_${last_pole}/list.txt | awk '{print $1}' | sed 's/.jpg$/.key/g' \
					> ${TOPDIR}/${dir}/$location/${dataset}_i${interval}_p${first_pole}_${last_pole}/list_keys.txt

			done
		done
	done
done


#
# run flann matches (NOTE: the flann matches uses all available cores. so no need to run in parallel)
#
for dir in $directories; do
	for dataset in $datasets; do
		for interval in $intervals; do
			for p in `seq 1 $loop_count`; do

				prev=`echo $p | awk '{print $1-1}'`
				first_pole=${poles[$prev]}
				last_pole=${poles[$p]}

				original_dir=`pwd`
				cd ${TOPDIR}/${dir}/$location/${dataset}_i${interval}_p${first_pole}_${last_pole}
				mkdir -p flann_matches
				rm -r flann_matches/*
				$MATCHER ${interval} ${MAX_FRAMES} list_keys.txt flann_matches/
				cd $original_dir

			done
		done
	done
done



#
# merge all flann matches into matches.init.txt (NOTE: run in parallel)
#
for dir in $directories; do
	for dataset in $datasets; do
		for interval in $intervals; do
			for p in `seq 1 $loop_count`; do

				prev=`echo $p | awk '{print $1-1}'`
				first_pole=${poles[$prev]}
				last_pole=${poles[$p]}

				path=${TOPDIR}/${dir}/$location/${dataset}_i${interval}_p${first_pole}_${last_pole}

				echo "./scripts/bundler/util/merge_flann_matches.sh $path"

			done
		done
	done
done | parallel



#
# run bundler (NOTE: run in paralell in background as we are changing directories)
#
for dir in $directories; do
	for dataset in $datasets; do
		for interval in $intervals; do
				

			pole_count=${#poles[@]}
			loop_count=`echo $pole_count | awk '{print $1-1}'`
			for p in `seq 1 $loop_count`; do


				prev=`echo $p | awk '{print $1-1}'`
				first_pole=${poles[$prev]}
				last_pole=${poles[$p]}

			
				path=${TOPDIR}/${dir}/$location/${dataset}_i${interval}_p${first_pole}_${last_pole}
				echo $path
				
				
				original_dir=`pwd`
			
				cp scripts/config_files_scripts/options.txt $path/
				cp scripts/config_files_scripts/clean.sh $path/
				cd $path
				mkdir -p bundle
				./clean.sh
				
				if [ "$dir" == "jpg360p" ]; then
					$BUNDLER_DIR/bundler list.txt --options_file options.txt  --init_focal_length 553.573003 --fixed_focal_length > bundle/bundle.log &
				elif [ "$dir" == "jpg720p" ]; then
					$BUNDLER_DIR/bundler list.txt --options_file options.txt  --init_focal_length 1108.211915 --fixed_focal_length > bundle/bundle.log &
				elif [ "$dir" == "jpg1080p" ]; then
					$BUNDLER_DIR/bundler list.txt --options_file options.txt  --init_focal_length 1661.576232 --fixed_focal_length > bundle/bundle.log &
				else
					echo "Invalid/unknown directory"
				fi

				cd $original_dir
			done
		done
	done
done


wait # wait for to finish all bundler jobs



#generate .infowcam files (NOTE: run in paralell in background as we are changing directories)  

for dir in $directories; do
	for dataset in $datasets; do
		for interval in $intervals; do
			
			pole_count=${#poles[@]}
			loop_count=`echo $pole_count | awk '{print $1-1}'`

			for p in `seq 1 $loop_count`; do
				prev=`echo $p | awk '{print $1-1}'`
				first_pole=${poles[$prev]}
				last_pole=${poles[$p]}

			
				path=${TOPDIR}/${dir}/$location/${dataset}_i${interval}_p${first_pole}_${last_pole}
				echo $path

				original_dir=`pwd` 

				cd $path

				#IMPORTANT: -m flag for mean of all features, -f=1 for including cams
				$BUNDLE2INFO -b bundle/bundle.out -l list.txt -o bundle.infowcam -f 1 &

				cd $original_dir
			done
		done
	done
done

wait #wait for the jobs to finish





echo "All bundler jobs done!"
