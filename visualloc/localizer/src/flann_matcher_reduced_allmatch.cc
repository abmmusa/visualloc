/******************************************************************************************************************
Copyright © 2015-2017, ABM Musa, University of Illinois at Chicago. All rights reserved.
Developed by:
ABM Musa
BITS Networked Systems Laboratory
University of Illinois at Chicago
http://www.cs.uic.edu/Bits
Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
and associated documentation files (the “Software”), to deal with the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions: -Redistributions of source code must retain the above copyright 
notice, this list of conditions and the following disclaimers. -Redistributions in binary form must 
reproduce the above copyright notice, this list of conditions and the following disclaimers in the 
documentation and/or other materials provided with the distribution. Neither the names of BITS Networked 
Systems Laboratory, University of Illinois at Chicago, nor the names of its contributors may be used 
to endorse or promote products derived from this Software without specific prior written permission.
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
OR THE USE OR OTHER DEALINGS WITH THE SOFTWARE.
********************************************************************************************************************/



//
// ratio ranked and linearly reduced feature matching as we move forward. Here, we match all frames but with interval. 
// For example, if the interal is 10, then the sequence for matching is: 0, 10, 20....n, 1, 11, 21, ... 
//

#include <vector>
#include <set>
#include <map>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <algorithm>
#include <stdint.h>
#include <string>
#include <algorithm>
#include <climits>
#include <float.h>
#include <cmath>
#include <sstream>
#include <stdio.h>
#include <sys/stat.h>

#include <boost/lexical_cast.hpp>

#include "features/SIFT_loader.hh"
#include <flann/flann.hpp>

#include "global.hh"
#include "util.hh"
#include "spatialfunc.hh"
#include "flann_matcher_reduced_allmatch.hh"



std::map<int, int> frame_index_map;

bool compareByRatio(const MatchData &a, const MatchData &b){
	return a.ratio < b.ratio;
}


int main(int argc, char **argv){

	if(argc != 5){
		std::cerr << "Usage: ./flann_matcher_reduced_allmatch interval max_frames list_match.txt matches_dir" << std::endl;
		exit(1);
	}

	struct stat info;
	stat(argv[4], &info);

	if( !(info.st_mode & S_IFDIR) ){
		std::cerr << "Directory doesn't exists!" << std::endl;
		exit(1);
	}

	int interval = atoi(argv[1]);
	int max_frames = atoi(argv[2]);
	std::ifstream file(argv[3]);
	std::string match_dir(argv[4]);


	SIFT_loader key_loader;
	std::string key_data;


	//
	//load keypoints and descriptors for all files in the list_keys.txt
	//
	
	int index_list = 0;
	while(std::getline(file, key_data)){
		//for(std::map<long, key_loc_data>::iterator it = keydata_map.begin(); it!=keydata_map.end(); ++it){

		std::vector<std::string> splitted_data;
		split(key_data, splitted_data, ' ');

		std::string key_filename = splitted_data[0];

		std::cout << "processing file " << key_filename << std::endl;



		std::string frame=remove_path_and_extension(key_filename);
		
		std::string erase_str = "frame";
		std::string::size_type erase_str_pos = frame.find(erase_str);
		
		if (erase_str_pos != std::string::npos){
			frame.erase(erase_str_pos, erase_str.length());
		}else{
			std::cout << "Invalid frame string!" << std::endl;
			exit(1);
		}

		key_loader.load_features( key_filename.c_str(), LOWE );
		std::vector< SIFT_keypoint >& keypoints = key_loader.get_keypoints();	
		std::vector< uchar* >& descriptors = key_loader.get_descriptors();
	
		uint32_t nb_loaded_keypoints = (uint32_t) keypoints.size();

		frame_index_map[atoi(frame.c_str())] = index_list;

		ImageData imgdata; 
		imgdata.frame_no = atoi(frame.c_str());
		imgdata.kp_count = nb_loaded_keypoints;
		imgdata.file_path = key_filename;
		imgdata.keypoints = keypoints;
		imgdata.descriptors = descriptors; //TODO: fix this. since it's pointer of bytes, it's not being deep copied

		float* features = (float*)malloc(nb_loaded_keypoints * 128 * sizeof(float));
	
		for(size_t j=0; j<nb_loaded_keypoints; j++){
			uchar *desc = new uchar[128];
			desc = descriptors[j];
			for( uint32_t k=0; k<128; ++k ){
				features[j*128+k] = desc[k];
			}
		
		}

		flann::Matrix< float > mFlannFeatures(features, nb_loaded_keypoints, 128);
		flann::Index<flann::L2<float> > index(mFlannFeatures, flann::KDTreeIndexParams(4)); 
		index.buildIndex();

		imgdata.features = features;
		imgdata.index = new flann::Index< flann::L2<float> > (index);
	
		imageDataList.push_back(imgdata);

		index_list++;
	}	


	//
	// match every image with later images in the list
	//


	int frames_to_be_matched = max_frames;
	int match_count_step_reduction = (MAX_MATCH_COUNT - MIN_MATCH_COUNT)/frames_to_be_matched;
	
	
#pragma omp parallel for
	for(size_t current_index=0; current_index<imageDataList.size(); current_index++){

		size_t current_frame = imageDataList[current_index].frame_no;
	   
		for(size_t next_frame=current_frame+1; next_frame<=current_frame+max_frames && next_frame<frame_index_map.rbegin()->first; next_frame++){ 
			if(current_frame==next_frame) continue;

			std::cout << "matching images " << current_frame << " " << next_frame << std::endl; 
		
			size_t next_index = frame_index_map[next_frame];

			std::cout << current_frame << " " << next_frame << " " << current_index << " " << next_index << " " \
			          << imageDataList[current_index].kp_count << " " << imageDataList[next_index].kp_count << std::endl;
	
		
			
			
			flann::Matrix<int> indices(new int[imageDataList[current_index].kp_count*2], imageDataList[current_index].kp_count, 2); 
			flann::Matrix<float> dists(new float[imageDataList[current_index].kp_count*2], imageDataList[current_index].kp_count, 2);
			
			flann::Matrix< float > mFlannFeatures(imageDataList[current_index].features, imageDataList[current_index].kp_count, 128);
			imageDataList[next_index].index->knnSearch(mFlannFeatures, indices, dists, 2, flann::SearchParams(128));
				

			std::vector<MatchData> mdataVec;
			mdataVec.clear();
			for(size_t k=0; k<imageDataList[current_index].kp_count; k++){

				MatchData mdata;
				mdata.self_feature_index = k;
				mdata.matched_feature_index = indices[k][0];
				mdata.ratio = dists[k][0]/dists[k][1];

				mdataVec.push_back(mdata);
			}

			std::sort(mdataVec.begin(), mdataVec.end(), compareByRatio);

			std::vector< std::pair<int, int> > all_matches;
			all_matches.clear();							
			for(size_t a=0; a<mdataVec.size(); a++){

				if(a>MAX_MATCH_COUNT){
					break;
				}

				std::pair<int, int> match_pair(mdataVec[a].self_feature_index, mdataVec[a].matched_feature_index);
				all_matches.push_back(match_pair);
			}


			std::string outfilename = match_dir+"/frame-"+patch::to_string(current_index)+"-"+patch::to_string(next_index)+".txt";
			std::ofstream outfile(outfilename.c_str());

			outfile << all_matches.size() << std::endl;
			
			for(size_t k=0; k<all_matches.size(); k++){
				outfile << all_matches[k].first << " " << all_matches[k].second << std::endl;
			}
			
		}
	}

}
