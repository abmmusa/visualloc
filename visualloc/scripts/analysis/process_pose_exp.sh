#!/bin/bash



FRAMES_DIR="/home/musa/research/visualloc"


###################################
# Error plots
###################################

#
#taylor
#
 
# not mean

# for interval in 10 20; do
# 	for count in 100 300 500; do
# 		for error in 10.0; do

# 			camera_total=`cat $FRAMES_DIR/bundler_output_ratioranked/jpg720p/taylor/gimbalwest_03222016_walk1_${interval}/bundle/bundle.out |  awk 'NR==2 {print $1}'`
# 			camera_first=`cat $FRAMES_DIR/bundler_output_ratioranked/jpg720p/taylor/gimbalwest_03222016_walk1_${interval}/bundle/bundle.out | \
# 				awk 'NR>2 && NR<=total_cam*5+2 {print}' total_cam=$camera_total | awk 'NR%5==0 {printf "%.6f %.6f %.6f\n", $1, $2, $3}'| head -1`
# 			camera_last=`cat $FRAMES_DIR/bundler_output_ratioranked/jpg720p/taylor/gimbalwest_03222016_walk1_${interval}/bundle/bundle.out  | \
# 				awk 'NR>2 && NR<=total_cam*5+2 {print}' total_cam=$camera_total | awk 'NR%5==0 {printf "%.6f %.6f %.6f\n", $1, $2, $3}'| tail -1`
			
# 			model_distance=`echo $camera_first $camera_last | awk '{print sqrt(($4-$1)**2 + ($5-$2)**2 + ($6-$3)**2)}'`
# 			unit_distance=`echo $model_distance | awk '{print 291/$1}'` # TAYLOR experiment length in meters, 955 feet.

# 			echo $model_distance $unit_distance

# 			#same day
# 			gawk 'ARGIND==1 {x[$1]=$8; y[$1]=$9; z[$1]=$10; next} {print $1, $8, x[$1], $9, y[$1], $10, z[$1], sqrt(($8-x[$1])**2+($9-y[$1])**2+($10-z[$1])**2)}' pose_output_exp/jpg720p/taylor/loc_count${count}_error${error}_gimbalwest_corrected_03222016_walk1_${interval}.txt pose_output_exp/jpg720p/taylor/loc_count${count}_error${error}_gimbalwest_corrected_03222016_walk2_${interval}.txt | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $8*unit_dis}' unit_dis=$unit_distance > processed_data/jpg720p/exp/errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

# 			# diff day
# 			gawk 'ARGIND==1 {x[$1]=$8; y[$1]=$9; z[$1]=$10; next} {print $1, $8, x[$1], $9, y[$1], $10, z[$1], sqrt(($8-x[$1])**2+($9-y[$1])**2+($10-z[$1])**2)}' pose_output_exp/jpg720p/taylor/loc_count${count}_error${error}_gimbalwest_corrected_03222016_walk1_${interval}.txt pose_output_exp/jpg720p/taylor/loc_count${count}_error${error}_gimbalwest_corrected_03212016_walk1_${interval}.txt | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $8*unit_dis}' unit_dis=$unit_distance > processed_data/jpg720p/exp/errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt
			
# 			#
# 			#unfiltered
# 			#
# 			# same day
# 			cat processed_data/jpg720p/exp/errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt | awk '{print $9}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

# 			# diff day
# 			cat processed_data/jpg720p/exp/errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt | awk '{print $9}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt
			
# 			#
# 			#filtered
# 			#
# 			# same day
# 			cat processed_data/jpg720p/exp/errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt | grep -v '^$' | awk '{print $9}' | awk '$1<30 {print}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_filtered_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

# 			# diff day
# 			cat processed_data/jpg720p/exp/errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt | grep -v '^$' | awk '{print $9}' | awk '$1<30 {print}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_filtered_errorloc_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt


# 			for reduction in 10 5 2; do
# 			    #same day
# 				gawk 'ARGIND==1 {x[$1]=$8; y[$1]=$9; z[$1]=$10; next} {print $1, $8, x[$1], $9, y[$1], $10, z[$1], sqrt(($8-x[$1])**2+($9-y[$1])**2+($10-z[$1])**2)}' pose_output_exp/jpg720p/taylor/loc_bundlegt${reduction}_count${count}_error${error}_gimbalwest_corrected_03222016_walk1_${interval}.txt pose_output_exp/jpg720p/taylor/loc_bundlegt${reduction}_count${count}_error${error}_gimbalwest_corrected_03222016_walk2_${interval}.txt | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $8*unit_dis}' unit_dis=$unit_distance > processed_data/jpg720p/exp/errorloc_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

# 			    # diff day
# 				gawk 'ARGIND==1 {x[$1]=$8; y[$1]=$9; z[$1]=$10; next} {print $1, $8, x[$1], $9, y[$1], $10, z[$1], sqrt(($8-x[$1])**2+($9-y[$1])**2+($10-z[$1])**2)}' pose_output_exp/jpg720p/taylor/loc_bundlegt${reduction}_count${count}_error${error}_gimbalwest_corrected_03222016_walk1_${interval}.txt pose_output_exp/jpg720p/taylor/loc_bundlegt${reduction}_count${count}_error${error}_gimbalwest_corrected_03212016_walk1_${interval}.txt | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $8*unit_dis}' unit_dis=$unit_distance > processed_data/jpg720p/exp/errorloc_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt
			
# 			    #
# 			    #unfiltered
# 			    #
# 			    # same day
# 				cat processed_data/jpg720p/exp/errorloc_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt | awk '{print $9}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_errorloc_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

# 			    # diff day
# 				cat processed_data/jpg720p/exp/errorloc_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt | awk '{print $9}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_errorloc_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt
			
# 			    #
# 			    #filtered
# 			    #
# 			    # same day
# 				cat processed_data/jpg720p/exp/errorloc_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt | grep -v '^$' | awk '{print $9}' | awk '$1<30 {print}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

# 			    # diff day
# 				cat processed_data/jpg720p/exp/errorloc_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt | grep -v '^$' | awk '{print $9}' | awk '$1<30 {print}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_filtered_errorloc_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt

# 			done

# 		done
# 	done
# done



#
# mean
#
for interval in 10 20; do
	for count in 100 300 500; do
		for error in 10.0; do

			camera_total=`cat $FRAMES_DIR/bundler_output_ratioranked/jpg720p/taylor/gimbalwest_03222016_walk1_${interval}/bundle/bundle.out |  awk 'NR==2 {print $1}'`
			camera_first=`cat $FRAMES_DIR/bundler_output_ratioranked/jpg720p/taylor/gimbalwest_03222016_walk1_${interval}/bundle/bundle.out | \
				awk 'NR>2 && NR<=total_cam*5+2 {print}' total_cam=$camera_total | awk 'NR%5==0 {printf "%.6f %.6f %.6f\n", $1, $2, $3}'| head -1`
			camera_last=`cat $FRAMES_DIR/bundler_output_ratioranked/jpg720p/taylor/gimbalwest_03222016_walk1_${interval}/bundle/bundle.out  | \
				awk 'NR>2 && NR<=total_cam*5+2 {print}' total_cam=$camera_total | awk 'NR%5==0 {printf "%.6f %.6f %.6f\n", $1, $2, $3}'| tail -1`
			
			model_distance=`echo $camera_first $camera_last | awk '{print sqrt(($4-$1)**2 + ($5-$2)**2 + ($6-$3)**2)}'`
			unit_distance=`echo $model_distance | awk '{print 291/$1}'` # TAYLOR experiment length in meters, 955 feet.

			echo $model_distance $unit_distance

			#same day
			gawk 'ARGIND==1 {x[$1]=$8; y[$1]=$9; z[$1]=$10; next} {print $1, $8, x[$1], $9, y[$1], $10, z[$1], sqrt(($8-x[$1])**2+($9-y[$1])**2+($10-z[$1])**2)}' pose_output_exp/jpg720p/taylor/loc_mean_count${count}_error${error}_gimbalwest_corrected_03222016_walk1_${interval}.txt pose_output_exp/jpg720p/taylor/loc_mean_count${count}_error${error}_gimbalwest_corrected_03222016_walk2_${interval}.txt | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $8*unit_dis}' unit_dis=$unit_distance > processed_data/jpg720p/exp/errorloc_mean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

			# diff day
			gawk 'ARGIND==1 {x[$1]=$8; y[$1]=$9; z[$1]=$10; next} {print $1, $8, x[$1], $9, y[$1], $10, z[$1], sqrt(($8-x[$1])**2+($9-y[$1])**2+($10-z[$1])**2)}' pose_output_exp/jpg720p/taylor/loc_mean_count${count}_error${error}_gimbalwest_corrected_03222016_walk1_${interval}.txt pose_output_exp/jpg720p/taylor/loc_mean_count${count}_error${error}_gimbalwest_corrected_03212016_walk1_${interval}.txt | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $8*unit_dis}' unit_dis=$unit_distance > processed_data/jpg720p/exp/errorloc_mean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt
			
			#
			#unfiltered
			#
			# same day
			cat processed_data/jpg720p/exp/errorloc_mean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt | awk '{print $9}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_errorloc_mean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

			# diff day
			cat processed_data/jpg720p/exp/errorloc_mean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt | awk '{print $9}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_errorloc_mean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt
			
			#
			#filtered
			#
			# same day
			cat processed_data/jpg720p/exp/errorloc_mean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt | grep -v '^$' | awk '{print $9}' | awk '$1<30 {print}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_filtered_errorloc_mean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

			# diff day
			cat processed_data/jpg720p/exp/errorloc_mean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt | grep -v '^$' | awk '{print $9}' | awk '$1<30 {print}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_filtered_errorloc_mean_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt


			for reduction in 10 5 2; do
			    #same day
				gawk 'ARGIND==1 {x[$1]=$8; y[$1]=$9; z[$1]=$10; next} {print $1, $8, x[$1], $9, y[$1], $10, z[$1], sqrt(($8-x[$1])**2+($9-y[$1])**2+($10-z[$1])**2)}' pose_output_exp/jpg720p/taylor/loc_mean_bundlegt${reduction}_count${count}_error${error}_gimbalwest_corrected_03222016_walk1_${interval}.txt pose_output_exp/jpg720p/taylor/loc_mean_bundlegt${reduction}_count${count}_error${error}_gimbalwest_corrected_03222016_walk2_${interval}.txt | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $8*unit_dis}' unit_dis=$unit_distance > processed_data/jpg720p/exp/errorloc_mean_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

			    # diff day
				gawk 'ARGIND==1 {x[$1]=$8; y[$1]=$9; z[$1]=$10; next} {print $1, $8, x[$1], $9, y[$1], $10, z[$1], sqrt(($8-x[$1])**2+($9-y[$1])**2+($10-z[$1])**2)}' pose_output_exp/jpg720p/taylor/loc_mean_bundlegt${reduction}_count${count}_error${error}_gimbalwest_corrected_03222016_walk1_${interval}.txt pose_output_exp/jpg720p/taylor/loc_mean_bundlegt${reduction}_count${count}_error${error}_gimbalwest_corrected_03212016_walk1_${interval}.txt | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $8*unit_dis}' unit_dis=$unit_distance > processed_data/jpg720p/exp/errorloc_mean_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt
			
			    #
			    #unfiltered
			    #
			    # same day
				cat processed_data/jpg720p/exp/errorloc_mean_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt | awk '{print $9}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_errorloc_mean_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

			    # diff day
				cat processed_data/jpg720p/exp/errorloc_mean_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt | awk '{print $9}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_errorloc_mean_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt
			
			    #
			    #filtered
			    #
			    # same day
				cat processed_data/jpg720p/exp/errorloc_mean_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt | grep -v '^$' | awk '{print $9}' | awk '$1<30 {print}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_filtered_errorloc_mean_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03222016_walk2_${interval}.txt

			    # diff day
				cat processed_data/jpg720p/exp/errorloc_mean_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt | grep -v '^$' | awk '{print $9}' | awk '$1<30 {print}' | sort -n | cdf > processed_data/jpg720p/exp/cdf_filtered_errorloc_mean_bundlegt${reduction}_count${count}_error${error}_taylor_gimbalwest_corrected_03222016_walk1_gimbalwest_corrected_03212016_walk2_${interval}.txt

			done

		done
	done
done






# #
# #sce
# #

# # Fix for sce_gimbalsubway_03232015_walk2 as it's off by 1
# # TODO: see if it's necessary and also rename frames
# for interval in 10 20; do
# 	for count in 100 300 500; do
# 		for error in 10.0; do
			
			
# 			cat pose_output_exp/jpg720p/sce/loc_count${count}_error${error}_gimbalsubway_03232015_walk2_${interval}.txt | sort -n | awk '{print $1+1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' > /tmp/loc_count${count}_error${error}_gimbalsubway_03232015_walk2_${interval}.txt

			
# 			# for reduction in ${reductions}; do
# 			# 	cat pose_output_ratioranked/exp/jpg720p/loc_bundlegt${reduction}_count${count}_error${error}_sce_gimbalsubway_03232015_walk2_${interval}.txt | sort -n | awk '{print $1+1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' > /tmp/loc_bundlegt${reduction}_count${count}_error${error}_sce_gimbalsubway_03232015_walk2_${interval}.txt
# 			# done
			

# 		done
# 	done
# done


# for interval in 10 20; do
# 	for count in 100 300 500; do
# 		for error in 10.0; do

# 			camera_total=`cat $FRAMES_DIR/bundler_output_ratioranked/jpg720p/sce/gimbalsubway_03232015_walk1_${interval}/bundle/bundle.out |  awk 'NR==2 {print $1}'`

# 			#camera_first=`cat bundler_output_ratioranked/jpg720p/sce/gimbalsubway_03232015_walk1_${interval}/bundle/bundle.out | \
# 			#awk 'NR>2 && NR<=total_cam*5+2 {print}' total_cam=$camera_total | awk 'NR%5==0 {printf "%.6f %.6f %.6f\n", $1, $2, $3}'| head -1`

# 			camera_first="16.484493 5.162882 -36.389224"
# 			camera_last=`cat $FRAMES_DIR/bundler_output_ratioranked/jpg720p/sce/gimbalsubway_03232015_walk1_${interval}/bundle/bundle.out  | \
# 				awk 'NR>2 && NR<=total_cam*5+2 {print}' total_cam=$camera_total | awk 'NR%5==0 {printf "%.6f %.6f %.6f\n", $1, $2, $3}'| tail -1`
			
# 			model_distance=`echo $camera_first $camera_last | awk '{print sqrt(($4-$1)**2 + ($5-$2)**2 + ($6-$3)**2)}'`
# 			unit_distance=`echo $model_distance | awk '{print 132.59/$1}'` # SCE experiment length (meters), 435 feet #TODO: should we take all cameras as we don't evaluate for all

# 			echo $model_distance $unit_distance


# 			gawk 'ARGIND==1 {x[$1]=$8; y[$1]=$9; z[$1]=$10; next} {print $1, $8, x[$1], $9, y[$1], $10, z[$1], sqrt(($8-x[$1])**2+($9-y[$1])**2+($10-z[$1])**2)}' pose_output_exp/jpg720p/sce/loc_count${count}_error${error}_gimbalsubway_03232015_walk1_${interval}.txt /tmp/loc_count${count}_error${error}_gimbalsubway_03232015_walk2_${interval}.txt |  awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $8*unit_dis}' unit_dis=$unit_distance > processed_data/jpg720p/exp/errorloc_count${count}_error${error}_sce_gimbalsubway_03232015_walk1_gimbalsubway_03232015_walk2_${interval}.txt


# 			cat processed_data/jpg720p/exp/errorloc_count${count}_error${error}_sce_gimbalsubway_03232015_walk1_gimbalsubway_03232015_walk2_${interval}.txt | awk 'NR>=65 {print $9}' | grep -v '^$' | sort -n | cdf > processed_data/jpg720p/exp/cdf_errorloc_count${count}_error${error}_sce_gimbalsubway_03232015_walk1_gimbalsubway_03232015_walk2_${interval}.txt


# 		done		
# 	done
# done
