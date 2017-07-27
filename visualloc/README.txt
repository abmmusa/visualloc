localizer/src contains code for featuere matching for 3d reconstruction, pose estimation etc.

To compile:
1. cd localizer/build
2. cmake ..
3. make && make install


Scripts:
-----------------
scripts/bundler/run_matcher_bundler_twodatasets_interleaved_iphone_fivepoles.sh:
grouond truth reconstruction for interleaved ref dataset and all added frames

scripts/bundler/run_matcher_bundler_twodatasets_interleaved_mod_iphone_fivepoles.sh:
grouond truth reconstruction for interleaved ref dataset and interleaved(modded) added frames        


scripts/pose/run_pose_subdivided_wqueue_kalman.sh:
run the pose estimation algorithm

scripts/pose/evaluate.sh
produce evaluation results on pose accuracy

