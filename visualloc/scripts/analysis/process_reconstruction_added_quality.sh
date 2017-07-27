#!/bin/bash

PROJECT_DIR="/home/musa/research/visloc"


#
# added reconstruction
#

# mkdir -p reconstruction_data/dataset_frames_cams_added
# for dir in `ls bundler_added_output/jpg720p/tayloriphone/`; do

# 	original_dir=`pwd`
# 	echo $dir
# 	cd bundler_added_output/jpg720p/tayloriphone/$dir
	
# 	cat list.added.txt | awk '{print $1}' | awk -F/ '{print $(NF-1), $NF}' | sed 's/frame//g; s/.jpg//g' > /tmp/dataset_frame.txt
# 	cat bundle.added.out | ~/scripts/get_bundle_cams.sh > /tmp/bundle_cams.txt
# 	paste -d " " /tmp/dataset_frame.txt /tmp/bundle_cams.txt \
# 		> $PROJECT_DIR/reconstruction_data/dataset_frames_cams_added/${dir}.txt
	
# 	cd $original_dir
# done

#
# reconstruction for both datasets together
#
mkdir -p reconstruction_data/dataset_frames_cams_reconstructed
for dir in `ls bundler_twodatasets_output_interleaved/jpg720p/tayloriphone/`; do

	original_dir=`pwd`
	echo $dir
	cd bundler_twodatasets_output_interleaved/jpg720p/tayloriphone/$dir
	
	cat list_ref_added.txt | awk '{print $1}' | awk -F/ '{print $(NF-1), $NF}' | sed 's/frame//g; s/.jpg//g' > /tmp/dataset_frame.txt
	cat bundle_ref_added/bundle_ref_added.out | ~/scripts/get_bundle_cams.sh > /tmp/bundle_cams.txt
	paste -d " " /tmp/dataset_frame.txt /tmp/bundle_cams.txt \
		> $PROJECT_DIR/reconstruction_data/dataset_frames_cams_reconstructed/${dir}.txt
	
	cd $original_dir
done


# for dir in $directories; do
# 	for interval in $interval; do
# 		for dataset_ref in ${datasets[@]}; do
# 			for dataset_add in ${datasets[@]}; do
# 				if [ "$dataset_ref" != "$dataset_add" ]; then
# 					for p in `seq 1 $loop_count`; do
# 						prev=`echo $p | awk '{print $1-1}'`
# 						first_pole=${poles[$prev]}
# 						last_pole=${poles[$p]}

						
# 						path=${TOPDIR}/${dir}/$location/${dataset_ref}_${dataset_add}_i${interval}_p${first_pole}_${last_pole}
						
# 						echo $path $first_pole $last_pole 
						
# 						original_dir=`pwd`
# 						cd $path

# 						cat list.added.txt | awk '{print $1}' | awk -F/ '{print $(NF-1), $NF}' | sed 's/frame//g; s/.jpg//g' > /tmp/dataset_frame.txt
# 						cat bundle.added.out | ~/scripts/get_bundle_cams.sh > /tmp/bundle_cams.txt
# 						paste -d " " /tmp/dataset_frame.txt /tmp/bundle_cams.txt \
# 							> $PROJECT_DIR/reconstruction_data/dataset_frames_cams_${dir}_${location}_${dataset_ref}_${dataset_add}_i${interval}_p${first_pole}_${last_pole}.txt

# 						cd $original_dir

# 					done
# 				fi
# 			done
# 		done
# 	done
# done

