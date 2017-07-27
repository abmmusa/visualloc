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
	mkdir -p plots_pose/pose_error/${dir}/${location}
	
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


# cdf of localization error
			
							cdf_raw_file="plot_data/pose_error/${dir}/${location}/cdferror_raw_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.txt"
							cdf_kalman_file="plot_data/pose_error/${dir}/${location}/cdferror_kalman_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.txt"
				
							plot_file="plots_pose/pose_error/${dir}/${location}/cdferror_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.pdf"

				
							gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2
set key above

set xlabel "Error (meters)"
set ylabel "Cumulative Distribution"
			
set output "$plot_file"
plot [:3][:] '$cdf_raw_file' u 2:1 w lines ti "Unfiltered", \
'$cdf_kalman_file' u 2:1 w lines ti "Filtered"

EOF


# orignial localization vs w/ kalman filter

							loc_file="pose_output_subdivided_wqueue_kalman_test/${dir}/${location}/loc_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.txt"
							plot_file="plots_pose/pose_error/${dir}/${location}/loc_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.pdf"
							
							gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2
set key above

set xlabel "Frame"
set ylabel "Error (meters)"
			
set output "$plot_file"
plot [:][:] '$loc_file' u 11 ti "Unfiltered locations", '' u 14 w lines ti "Kalman filtered location"

EOF


# tracking time

							loc_file="pose_output_subdivided_wqueue_kalman_test/${dir}/${location}/loc_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.txt"
							plot_file="plots_pose/pose_error/${dir}/${location}/time_subdiv${subdivision}_track${tracking}_${dataset_ref}_${dataset_test}_i${interval}_p${first_pole}_${last_pole}.pdf"
							
							gnuplot<<EOF
set terminal pdf font "Helvetica,12" lw 2
set key above

set xlabel "Frame"
set ylabel "Time (seconds)"
			
set output "$plot_file"
plot [:][:] '$loc_file' u 6 ti "Tracking time"

EOF



							
						done
					done
				done
			done
		done
	done
done

