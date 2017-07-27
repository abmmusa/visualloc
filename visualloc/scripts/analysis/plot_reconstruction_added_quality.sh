#!/bin/bash

PROJECT_DIR="/home/musa/research/visloc"



#
# added reconstruction
#
mkdir -p plots_reconstruction/dataset_frames_cams_added/
for f in `ls reconstruction_data/dataset_frames_cams_added/`; do
	datasets=`cat reconstruction_data/dataset_frames_cams_added/$f | awk '{print $1}' | uniq`
	
	dataset_ref=`echo $datasets | awk '{print $1}'`
	dataset_added=`echo $datasets | awk '{print $2}'`

	cat reconstruction_data/dataset_frames_cams_added/$f | awk '$1==d {print}' d=$dataset_ref > /tmp/cams_ref.txt
	cat reconstruction_data/dataset_frames_cams_added/$f | awk '$1==d {print}' d=$dataset_added > /tmp/cams_added.txt

	filename_plot=`echo $f | sed s/.txt/.pdf/g`

	gnuplot<<EOF
set terminal pdf font "Helvetica,10" lw 1 
set key above

set xlabel "Frame"
set ylabel "Z-value"
			
set output "plots_reconstruction/dataset_frames_cams_added/$filename_plot"
plot [:][:] '/tmp/cams_ref.txt' u 2:5 ti "Reference", '/tmp/cams_added.txt' u 2:5 ti "Added"

EOF

done





#
# reconstruction for both datasets together
#
mkdir -p plots_reconstruction/dataset_frames_cams_reconstructed/
for f in `ls reconstruction_data/dataset_frames_cams_reconstructed/`; do
	datasets=`cat reconstruction_data/dataset_frames_cams_reconstructed/$f | awk '{print $1}' | uniq`
	
	dataset_ref=`echo $datasets | awk '{print $1}'`
	dataset_reconstructed=`echo $datasets | awk '{print $2}'`

	cat reconstruction_data/dataset_frames_cams_reconstructed/$f | awk '$1==d {print}' d=$dataset_ref > /tmp/cams_ref.txt
	cat reconstruction_data/dataset_frames_cams_reconstructed/$f | awk '$1==d {print}' d=$dataset_added > /tmp/cams_added.txt

	filename_plot=`echo $f | sed s/.txt/.pdf/g`

	gnuplot<<EOF
set terminal pdf font "Helvetica,10" lw 1 
set key above

set xlabel "Frame"
set ylabel "Z-value"
			
set output "plots_reconstruction/dataset_frames_cams_reconstructed/$filename_plot"
plot [:][:] '/tmp/cams_ref.txt' u 2:5 ti "Reference", '/tmp/cams_added.txt' u 2:5 ti "Added"

EOF

done

