produce_sift_keys.sh: produces sift keys
run_matcher_bundler_allmatch_iphone.sh: 
runs flann matcher, bundler reconstruction for gap of 4 poles

run_matcher_bundler_allmatch_iphone_twopoles.sh: 
runs flann matcher, bundler reconstruction for gap of 2 poles

run_matcher_bundler_added_iphone.sh: 
runs flann matcher, bundler for added frames. added frames are used for ground truth. The idea here is that with a ref dataset A, we use dataset B reconstruction as ground truth for evaluation of location estimation by our algorithm for dataset B.

run_matcher_bundler_interleaved.sh:
runs the flann matcher, bundler reconstruction for interleaved frames (e.g., every 5, 10, etc.) only.

run_matcher_bundler_added_interleaved_iphone.sh:
runs flann matcher, bundler for added frames of *interleaved* reconsruction. added frames are used for ground truth. The idea here is that with a ref dataset A, we use dataset B reconstruction as ground truth for evaluation of location estimation by our algorithm for dataset B.


utils/merge_flann_matches.sh:
produces matches.init.txt from matches inside flann_matches/. used seprate script for paralelllization 

utils/get_poles_distance.sh:
returns distances between any two poles (pole distances were measured using the measuring wheel)
