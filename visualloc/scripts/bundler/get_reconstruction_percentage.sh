#!/bin/bash

######################################################################################
# compute how many frames are successfully reconstructed out of total given frames.
######################################################################################

TOPDIR=bundler_output_interleaved
dir=jpg720p

#
# taylor iphone
#
# location=tayloriphone

# for d in `ls $TOPDIR/$dir/$location`; do
# 	frame_count=`cat $TOPDIR/$dir/$location/$d/list.txt | wc -l`
# 	recon_count=`ls $TOPDIR/$dir/$location/$d/bundle | tail -1 | sed 's/points//g; s/.ply//g'`

# 	echo $d $frame_count $recon_count
# done | awk '{print $1, $2, $3, ($3/$2)*100}' > reconstruction_data/reconstruction_percentage/percentage_${TOPDIR}_${dir}_${location}.txt


#
# lakeshore
#
location=lakeshore

for d in `ls $TOPDIR/$dir/$location`; do
	frame_count=`cat $TOPDIR/$dir/$location/$d/list.txt | wc -l`
	recon_count=`ls $TOPDIR/$dir/$location/$d/bundle | tail -1 | sed 's/points//g; s/.ply//g'`

	echo $d $frame_count $recon_count
done | awk '{print $1, $2, $3, ($3/$2)*100}' > reconstruction_data/reconstruction_percentage/percentage_${TOPDIR}_${dir}_${location}.txt