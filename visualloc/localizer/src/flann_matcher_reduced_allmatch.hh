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



#ifndef FLANN_MATCHER_REDUCED_ALLMATCH_HH
#define FLANN_MATCHER_REDUCED_ALLMATCH_HH

#include <flann/flann.hpp>
#include "features/SIFT_loader.hh"


#define MAX_MATCH_COUNT 500
#define MIN_MATCH_COUNT 50
#define RATIO_CUTTOFF 0.9

typedef struct
{
	int frame_no; //frame no
	int kp_count; // the number of SIFT points
	std::string file_path; // the path to SIFT feature file

	std::vector< SIFT_keypoint > keypoints;
	std::vector< uchar* > descriptors;

	//flann::Matrix< float > *mFlannFeatures;
	float *features;
	flann::Index<flann::L2<float> > *index;
}ImageData; 



typedef struct
{
	size_t self_feature_index;
	size_t matched_feature_index;
	float ratio;
}MatchData; 


static std::vector<std::string> imageList;

static std::vector<ImageData> imageDataList;



#endif
