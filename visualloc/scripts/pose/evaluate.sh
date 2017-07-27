#!/bin/bash


#
# iphone
#
PROJECT_DIR="/home/musa/research/visloc"
IMG_DIR="/home/musa/research/imgloc"
FRAMES_DIR="/home/musa/research/visualloc"

directories="jpg720p"
intervals="10"



OUTPUT_TOPDIR="pose_output_subdivided_wqueue_kalman_test"

location="tayloriphone" 

#datasets=("gimbal_i6_11202015_walk1" "gimbal_i6_11202015_walk2")
datasets=("gimbal_i6_11202015_walk1" "gimbal_i6_11202015_walk2" "gimbal_i6_10212015_walk1" "chest_i6_11202015_walk1")

#poles=(0 5 10 15)
poles=(20 25 30 35 40)

pole_count=${#poles[@]}
loop_count=`echo $pole_count | awk '{print $1-1}'`


# for dir in $directories; do
# 	#for dataset in $datasets_iphone; do
# 	for interval in $intervals; do
# 		#for subdivision in 16 8 4 2 1; do
# 		for subdivision in 8 4; do
# 			#for tracking in 10 20 50 100; do
# 			for tracking in 10 100; do


for dir in $directories; do
	for dataset_ref in ${datasets[@]}; do
		for dataset_test in ${datasets[@]}; do
			for interval in $intervals; do
			    #for subdivision in 16 8 4 2 1; do
				for subdivision in 8 4; do
				    #for tracking in 10 20 50 100; do
					for tracking in 10 100; do

						for p in `seq 1 $loop_count`; do
							prev=`echo $p | awk '{print $1-1}'`
							first_pole=${poles[$prev]}
							last_pole=${poles[$p]}
							first_frame=`cat $PROJECT_DIR/log_data/$location/${dataset_test}/info_log_combined.txt | awk '$1==p {print $2}' p=$first_pole`
							last_frame=`cat $PROJECT_DIR/log_data/$location/${dataset_test}/info_log_combined.txt | awk '$1==p {print $2}' p=$last_pole`
										
							distance=`scripts/bundler/util/get_poles_distance.sh $first_pole $last_pole` 
											
							
							frame_gap=`echo $first_frame $last_frame | awk '{print $2-$1}'` #TODO: is it correct?
							distance_per_frame=`echo $distance $frame_gap | awk '{print $1/$2}'`
							echo $frame_gap $distance_per_frame
							frame_loc=0
							for f in `seq $first_frame $last_frame`; do
								echo $f $frame_loc
								frame_loc=`echo $frame_loc $distance_per_frame | awk '{print $1+$2}'`
							done > /tmp/ground_truth.txt
							
							
							loc_file=$OUTPUT_TOPDIR/${dir}/${location}/loc_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.txt
							cat $loc_file | awk -F/ '{print $NF}' | sed 's/frame//g; s/.key//g' > /tmp/loc_data.txt
							
							error_file=$OUTPUT_TOPDIR/${dir}/${location}/error_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.txt
			
							gawk 'ARGIND==1 {dist[$1]=$2;next} dist[$1] {print $0, -dist[$1]}' /tmp/ground_truth.txt /tmp/loc_data.txt | sort -n > $error_file #NOTE: minus sign as original reconstructed data as negative z

						done
					done
				done
			done
		done
	done
done


