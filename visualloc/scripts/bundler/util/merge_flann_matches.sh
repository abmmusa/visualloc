#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: merge_flann_matches.sh <path to flann_matches dir>"
	exit 1
fi

path=$1


original_dir=`pwd`
cd $path


suffix=`echo $RANDOM`
for f in `ls flann_matches/`; do 
	echo $f | sed 's/frame-//g; s/.txt//g; s/-/ /g' 
done | sort -n -k 1 -k 2 > /tmp/indices_${suffix}.txt

while read line; do
	echo $line
	file=`echo $line | awk '{print "frame-"$1"-"$2".txt"}'`
	cat flann_matches/$file 
done < /tmp/indices_${suffix}.txt > matches.init.txt

rm /tmp/indices_${suffix}.txt
cd $original_dir

