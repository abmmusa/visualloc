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





#ifndef POSE_ESTIMATOR_SUBDIVIDED_WQUEUE_KALMAN_HH
#define POSE_ESTIMATOR_SUBDIVIDED_WQUEUE_KALMAN_HH


#define TOTAL_NEIGHBORS 50 //2 is good enough for ratio test only

std::map<size_t, size_t> map_2d3d; //for every features, maps the corresponding 3d point

 
struct FeaturePoint{
	//for test feature
	float feature_x; 
	float feature_y;

	//ref points
	float point_x;
	float point_y;
	float point_z;

	float ratio;
	float feature_distance;
	float projection_error;

};



#endif
