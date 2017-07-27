#!/bin/bash


OUTPUT_TOPDIR="pose_output_subdivided_wqueue_kalman_test"

directories="jpg720p"
location="tayloriphone"

datasets=("gimbal_i6_11202015_walk1" "gimbal_i6_11202015_walk2")

intervals="10"

poles=(0 5 10 15)
pole_count=${#poles[@]}
loop_count=`echo $pole_count | awk '{print $1-1}'`



for dir in $directories; do
	mkdir -p plot_data/pose_error/${dir}/${location}
	
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
							
							error_file=$OUTPUT_TOPDIR/${dir}/${location}/error_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.txt
							
							cdf_raw_file=plot_data/pose_error/${dir}/${location}/cdferror_raw_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.txt
							cdf_kalman_file=plot_data/pose_error/${dir}/${location}/cdferror_kalman_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.txt


							cat $error_file | awk '{printf "%.6f\n", $NF-$11}'| awk '$1<0 {printf "%.6f\n", -$1} $1>=0 {printf "%.6f\n", $1}' | sort -n | cdf  > $cdf_raw_file
							cat $error_file | awk '{printf "%.6f\n", $NF-$(NF-1)}'| awk '$1<0 {printf "%.6f\n", -$1} $1>=0 {printf "%.6f\n", $1}' | sort -n | cdf  > $cdf_kalman_file

							
						done
					done
				done
			done
		done
	done
done

