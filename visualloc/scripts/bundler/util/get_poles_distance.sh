#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Usage: get_poles_distance.sh first_pole second_pole"
fi

cat distance_log/distances_meters.txt | awk '{print NR, $1}' | awk '$1>s && $1<=e {print $2}' s=$1 e=$2 | ~/scripts/sum
