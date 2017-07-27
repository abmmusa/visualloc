#!/bin/bash


IMG_DIR="/home/musa/research/imgloc"
#datasets="gimbal_i6_11202015_walk1 gimbal_i6_11202015_walk2"
#datasets="chest_i6_11202015_walk1 chest_i6_11202015_walk2 chest_i6_11022015_walk1 chest_i6_11022015_walk2 chest_i6_11112015_walk1 chest_i6_11112015_walk2"
datasets="gimbal_i6_10212015_walk1 gimbal_i6_10212015_walk2"
location="tayloriphone"

for dataset in $datasets; do

	mkdir -p log_data/${location}/${dataset}
	
    # merge time, locs, and frames (NOTE: only for sparsely recorded GPS locations)
	gawk 'ARGIND==1 {frames[$2]=$1; next} {minval=10000000; frameformin=-1; {for(x in frames) {gap=x-$1; if(gap>=0 && gap<minval) {minval=gap; frameformin=frames[x]}}};print $1, $3, $4, frameformin}' $IMG_DIR"/logs/taylor_st/$dataset/frames.txt" $IMG_DIR"/logs/taylor_st/$dataset/gps.txt" | awk '$4!=-1 {print}' > /tmp/time_loc_frame.txt

	
	cat /tmp/time_loc_frame.txt | python scripts/preprocess/util/generate_interpolated_trace.py > log_data/${location}/${dataset}/time_loc_frame_interpolated.txt
	

    # find the frames for clicks by closest time
	gawk 'ARGIND==1 {frames[$2]=$1; next} {minval=10000000; frameformin=-1; {for(x in frames) {gap=x-$2; if(gap>=0 && gap<minval) {minval=gap; frameformin=frames[x]}}};print $1, frameformin}' $IMG_DIR"/logs/taylor_st/$dataset/frames.txt" $IMG_DIR"/logs/taylor_st/$dataset/clicks.txt" > /tmp/pole_frames.txt


	poles=`cat $IMG_DIR"/logs/taylor_st/$dataset/clicks.txt" | awk '{print $1}'`
	for pole in $poles; do
		pole_time=`cat $IMG_DIR"/logs/taylor_st/$dataset/clicks.txt" | awk '$1==p {print $2}' p=$pole`
	    #echo $pole_time
		
		# TODO: generate this file
		info=`cat log_data/${location}/${dataset}/time_loc_frame_interpolated.txt | awk '{print $1-t, $2, $3}' t=$pole_time | \
			awk '$1<0 {print -$1, $2, $3} $1>=0 {print $1, $2, $3}' | \
			awk 'BEGIN{mintime=10000000000; pole_nearest=-1} $1<mintime {mintime=$1; info_nearest=$2" "$3} END{print info_nearest}'`
		
		echo $pole $info
	done > /tmp/pole_loc.txt
	
	paste -d " " /tmp/pole_frames.txt /tmp/pole_loc.txt | awk '{print $1, $2, $4, $5}' > log_data/${location}/$dataset/info_log_combined.txt

done


