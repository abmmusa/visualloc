#!/bin/bash



FRAMES_DIR="/home/musa/research/visualloc"

mkdir -p plots/jpg720p/exp/



###################################
# Error plots
###################################
#
# taylor
#
for interval in 10 20; do
	for count in 100 300 500; do
		for error in 10.0; do


			gnuplot<<EOF

            set terminal pdf font "Helvetica,12" lw 2
            set key above


			set xlabel "Frame"
			set ylabel "Error (meters)"
			
			set output "plots/jpg720p/exp/errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.pdf"
			plot [:][:10] \
				'processed_data/jpg720p/exp/errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 1:9 w linespoints ti "Same day walk", \
				'processed_data/jpg720p/exp/errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 1:9 w linespoints ti "Diff day walk"

			
			set xlabel "Error (meters)"
			set ylabel "Cumulative Distribution"
			
			set output "plots/jpg720p/exp/cdf_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.pdf"
			plot [:5][:] \
				'processed_data/jpg720p/exp/cdf_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Same day walk", \
				'processed_data/jpg720p/exp/cdf_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Diff day walk"
			

			set output "plots/jpg720p/exp/cdf_filtered_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.pdf"
			plot [:5][:] \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Same day walk", \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Diff day walk"
			


            #redocution comparision 
			set output "plots/jpg720p/exp/cdf_filtered_errorloc_compressed_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.pdf"
			plot [:5][:] \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Uncompressed", \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt2_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Min 2 frames", \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt5_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Min 5 frames", \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt10_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Min 10 frames"


			set output "plots/jpg720p/exp/cdf_filtered_errorloc_compressed_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.pdf"
			plot [:5][:] \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Uncompressed", \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt2_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Min 2 frames", \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt5_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Min 5 frames", \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt10_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Min 10 frames"


            #redocution comparision with mean
			set output "plots/jpg720p/exp/cdf_filtered_errorloc_compressed_withmean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.pdf"
			plot [:5][:] \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Uncompressed", \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt5_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Min 5 frames" lw 1, \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt10_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Min 10 frames" lw 1 ,\
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_mean_bundlegt5_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Min 5 frames and mean" lw 2, \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_mean_bundlegt10_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt' u 2:1 w lines ti "Min 10 frames and mean" lw 2


			set output "plots/jpg720p/exp/cdf_filtered_errorloc_compressed_withmean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.pdf"
			plot [:5][:] \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Uncompressed", \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt5_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Min 5 frames" lw 1, \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt10_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Min 10 frames" lw 1,\
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_mean_bundlegt5_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Min 5 frames and mean" lw 2, \
				'processed_data/jpg720p/exp/cdf_filtered_errorloc_mean_bundlegt10_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt' u 2:1 w lines ti "Min 10 frames and mean" lw 2





EOF


			

			#for reduction in 10 5 2; do

			#done

		done
	done
done





# #
# # sce
# #
# for interval in 10 20; do
# 	for count in 100 300 500; do
# 		for error in 10.0; do


# 			gnuplot<<EOF

# 			set terminal pdf font "Helvetica,12" lw 2
# 			set key above


# 			set xlabel "Frame"
# 			set ylabel "Error (meters)"
			
# 			set output "plots/jpg720p/exp/errorloc_count${count}_error${error}_sce_gimbalsubway_03232015_walk1_gimbalsubway_03232015_walk2_${interval}.pdf"
# 			plot [:][:10] 'processed_data/jpg720p/exp/errorloc_count${count}_error${error}_sce_gimbalsubway_03232015_walk1_gimbalsubway_03232015_walk2_${interval}.txt' u 1:9 w linespoints ti ""

			
# 			set xlabel "Error (meters)"
# 			set ylabel "Cumulative Distribution"
			
# 			set output "plots/jpg720p/exp/cdf_errorloc_count${count}_error${error}_sce_gimbalsubway_03232015_walk1_gimbalsubway_03232015_walk2_${interval}.pdf"
# 			plot [:5][:] 'processed_data/jpg720p/exp/cdf_errorloc_count${count}_error${error}_sce_gimbalsubway_03232015_walk1_gimbalsubway_03232015_walk2_${interval}.txt' u 2:1 w lines ti ""

			
			

# EOF



# 		done
# 	done
# done






