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
#include <pthread.h>

#include <opencv/cv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/video/tracking.hpp>
#include <opencv2/features2d/features2d.hpp>
#include "opencv2/nonfree/features2d.hpp"
#include <opencv2/nonfree/nonfree.hpp>


#include "global.hh"
#include "util.hh"

// includes for classes dealing with SIFT-features
#include "features/SIFT_loader.hh"


//FlANN 
#include <flann/flann.hpp>


// RANSAC
#include "RANSAC.hh"

//Bundle data parser
#include "sfm/parse_bundler.hh"


#include "wqueue.hh"
#include "kalman.hh"
#include "pose_estimator_subdivided_wqueue_kalman.hh"

bool debug=false;


#define TOTAL_THREADS 8
#define MAX_SQUARED_ERROR_BACKPROJECTION 100 //TODO: we might want to parameterize this number.

float calibration_distance = 100.0; // hard-coded for now. 100 meters between first and last camera. 

//#define SHOW_FLOW_SCREEN
#define WRITE_FLOW_IMAGE

parse_bundler parser;


int img_width;
int img_height;
int subdivision = 8;
int tracking_count = 50;
std::string info_file = "";
std::string list_file = "";
std::string out_filename = "";
std::string computation_type = "ratiotested"; //ratioranked, constrained



std::string debug_filename="debug_data/pose_estimation_subdivided_wqueue_kalman/debug.txt";
std::ofstream ofs_debug;

std::string vis_dirname="";

cv::TermCriteria termcrit(cv::TermCriteria::COUNT|cv::TermCriteria::EPS,20,0.03);
cv::Size subPixWinSize(10,10), winSize(31,31);



std::vector<FeaturePoint> test_kp_data_vec; 


cv::Mat gray, prevGray, image;
std::vector<cv::Point2f> points_first, points_second;

flann::Index< flann::L2<float> > *index_ptr;



std::string key_filename;
std::string key_filename_threaded;

cv::Ptr<cv::FeatureDetector> pdetector;
cv::Ptr<cv::DescriptorExtractor> pextractor;


Util::Math::ProjMatrix proj_matrix_prev;
// = ransac_solver.get_projection_matrix();

RANSAC ransac_solver;

struct ThreadData{
	cv::Mat image;
	int top; 
	int left;	
};


struct MatchInfo
{
	int index;
	float distance;
	float proj_error;
};


wqueue<ThreadData> queue; //thread safe work queue

pthread_barrier_t barrier; 


std::vector< feature_3D_info >& feature_infos = parser.get_feature_infos(); //TODO: this is BAD. we need to use load_from_binary() first


pthread_mutex_t mutex_write=PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutex_debug=PTHREAD_MUTEX_INITIALIZER;



int frame_counter = 0; //using here for outputting in the debug file. can be declared in main too.


bool compareByFeatureDistance(const FeaturePoint &a, const FeaturePoint &b){
	return a.feature_distance < b.feature_distance;
}


bool is_existing_keypoint_xy(const FeaturePoint &kp_data){ 
	for(size_t k=0; k < test_kp_data_vec.size(); k++){
		FeaturePoint kp_data_existing = test_kp_data_vec[k];
		if(kp_data_existing.feature_x == kp_data.feature_x && kp_data_existing.feature_y == kp_data.feature_y){
			return true;
		}
	}
	
	return false;
}


float get_projection_error(const float feature_x, const float feature_y, const int feature_index, const int neighbor_index, const flann::Matrix<int> &indices){
	std::vector<float> feature_2D, point_3D;
	
	feature_2D.push_back(feature_x - (img_width-1.0)/2.0f);
	feature_2D.push_back((img_height-1.0)/2.0f - feature_y);

	uint32_t point_id = map_2d3d[ indices[feature_index][neighbor_index] ];			
	float point_x = feature_infos[point_id].point.x;
	float point_y = feature_infos[point_id].point.y;
	float point_z = feature_infos[point_id].point.z;
	
	point_3D.push_back(point_x);
	point_3D.push_back(point_y);
	point_3D.push_back(point_z);
	point_3D.push_back(1.0);			
	
	float proj_error = ransac_solver.evaluate_correspondece_error(feature_2D, point_3D); //TODO: some return values are negative. How is that?? It's squared. see at solver/solverproj.cc
	if(debug){
		if( pthread_mutex_lock(&mutex_debug) != 0 ) perror("write mutex lock failed");			
		ofs_debug << ransac_solver.get_projection_matrix() << std::endl;
		ofs_debug << proj_error << std::endl;
		if( pthread_mutex_unlock(&mutex_debug) != 0 ) perror("write mutex unlock failed");
	}



	//std::cout << feature_2D << " " << point_3D << std::endl;
	//std::cout << "proj error=" << proj_error << std::endl;
   
	return proj_error;
}




flann::Index< flann::L2<float> > load_bundler_info(std::string info_file){
	//
	// load the Bundler data
	//
	std::cout << "-> parsing the bundler output from " << info_file << std::endl;
	//parser.load_from_binary( info_file.c_str(), 0 ); //0 is for bundle type if .info file is generated using Bundle2Info
	parser.load_from_binary( info_file.c_str(), 1 ); //0 is for bundle type if .info file is generated using Bundle2Info, use 1 for having camera infos too
	std::vector< feature_3D_info >& feature_infos = parser.get_feature_infos();
  
	uint32_t nb_cameras = parser.get_number_of_cameras();
	uint32_t nb_points = parser.get_number_of_points();

	std::cout << nb_cameras << " " << nb_points << std::endl;
 
	std::cout << "--> done parsing the bundler output " << std::endl;


	//
	// reproject bundler output to fit real-world dimensions and orientation.		 
	//
	const std::vector< bundler_camera > cameras = parser.get_cameras();
	std::cout << "found cameras " << cameras.size() << std::endl;

	const OpenMesh::Vec3d &origin = parser.get_cameras()[0].get_cam_position_d();
	const OpenMesh::Vec3d &destination = parser.get_cameras()[nb_cameras-2].get_cam_position_d(); 
	double dist = (destination-origin).norm();	

	for(uint32_t i=0; i<cameras.size(); i++){
		std::cout << parser.get_cameras()[i].get_cam_position_d() << std::endl;
	}
	

	// angle rotated around y axis
	double y_angle = atan2(destination[0]-origin[0],destination[2]-origin[2]);
	// angle rotated around x axis
	double x_angle = atan2(destination[1]-origin[1],destination[2]-origin[2]); 

	std::cout << "origin: " << origin << " dest: " << destination << " distance:" << dist << " xangle: "<<x_angle<<" yangle: "<<y_angle<<std::endl;


	for( uint32_t i=0; i<cameras.size(); ++i ){
		OpenMesh::Vec3d cam_pos = parser.get_cameras()[i].get_cam_position_d();
		cam_pos[0] -= origin[0];
		cam_pos[1] -= origin[1];
		cam_pos[2] -= origin[2];

		cam_pos[0] *= calibration_distance/dist; 
		cam_pos[1] *= calibration_distance/dist; 
		cam_pos[2] *= calibration_distance/dist; 

		cam_pos[0] = cam_pos[0]*cos(-y_angle)+cam_pos[2]*sin(-y_angle);
		cam_pos[2] = -cam_pos[0]*sin(-y_angle)+cam_pos[2]*cos(-y_angle);

		cam_pos[1] = cam_pos[1]*cos(-x_angle)-cam_pos[2]*sin(-x_angle);
		cam_pos[2] = cam_pos[1]*sin(-x_angle)+cam_pos[2]*cos(-x_angle);

		std::cout << cam_pos[0] << " " << cam_pos[1] << " " << cam_pos[2] << std::endl;
	}


	// update every point
	for( uint32_t i=0; i<nb_points; ++i ){
		feature_infos[i].point.x -= origin[0];
		feature_infos[i].point.y -= origin[1];
		feature_infos[i].point.z -= origin[2];

		feature_infos[i].point.x *= calibration_distance/dist; 
		feature_infos[i].point.y *= calibration_distance/dist; 
		feature_infos[i].point.z *= calibration_distance/dist; 

		feature_infos[i].point.x = feature_infos[i].point.x*cos(-y_angle)+feature_infos[i].point.z*sin(-y_angle);
		feature_infos[i].point.z = -feature_infos[i].point.x*sin(-y_angle)+feature_infos[i].point.z*cos(-y_angle);

		feature_infos[i].point.y = feature_infos[i].point.y*cos(-x_angle)-feature_infos[i].point.z*sin(-x_angle);
		feature_infos[i].point.z = feature_infos[i].point.y*sin(-x_angle)+feature_infos[i].point.z*cos(-x_angle);
	}



	//
	// count total featuers from all 3d points
	// 
	uint32_t total_features_bundler = 0;
	for( uint32_t i=0; i<nb_points; ++i ){
		uint32_t nb_cams_visible_in = (uint32_t) feature_infos[i].view_list.size();
		total_features_bundler+=nb_cams_visible_in;
	}

	std::cout << "Total features bundler=" << total_features_bundler << std::endl;

	//
	// Fill up features_ref from bundler file
	//
	float* features_ref = (float*)malloc(total_features_bundler * 128 * sizeof(float));
	if(features_ref == NULL){
		std::cout << "malloc() failed" << std::endl;
		exit(1);
	}



	size_t counter_2d = 0;

	for( uint32_t i=0; i<nb_points; ++i ){
		uint32_t nb_cams_visible_in = (uint32_t) feature_infos[i].view_list.size();

		// for every camera: the keypoint data and the descriptor
		for( uint32_t j=0; j<nb_cams_visible_in; ++j ){

			float feature_new[128];

			uint32_t cam = feature_infos[i].view_list[j].camera;
			float x = feature_infos[i].view_list[j].x;
			float y = feature_infos[i].view_list[j].y;

			float scale = feature_infos[i].view_list[j].scale;
			float orientation = feature_infos[i].view_list[j].orientation;
			
			//std::cout << x << " " << y << std::endl;
			
			for( uint32_t k=0; k<128; ++k ){
				features_ref[counter_2d*128+k] = (float)feature_infos[i].descriptors[128*j+k];
			}
			
			map_2d3d[counter_2d] = i;

			counter_2d++;
		}    
	}
	
	
	flann::Matrix< float > mFlannFeatures(features_ref, total_features_bundler, 128); // all features
	flann::Index<flann::L2<float> > index(mFlannFeatures, flann::KDTreeIndexParams(4)); 
	index.buildIndex();

	return index;
}



void process_first_frame(cv::Mat image){
	std::vector<cv::KeyPoint> keypoints_test;
	cv::Mat descriptors_test;
	
	pdetector->detect(image, keypoints_test);
	pextractor->compute(image, keypoints_test, descriptors_test);


	uint32_t nb_keypoints = (uint32_t) keypoints_test.size();		
	
	float* features_test = (float*)malloc(nb_keypoints * 128 * sizeof(float));
	
	for(size_t j=0; j<nb_keypoints; j++){
		for( uint32_t k=0; k<128; ++k ){
			features_test[j*128+k] = descriptors_test.at<float>(j,k);
		}
	}

	
	flann::Matrix< float > mFlannFeaturesTest(features_test, nb_keypoints, 128);

	flann::Matrix<int> indices(new int[nb_keypoints*TOTAL_NEIGHBORS], nb_keypoints, TOTAL_NEIGHBORS); 
	flann::Matrix<float> dists(new float[nb_keypoints*TOTAL_NEIGHBORS], nb_keypoints, TOTAL_NEIGHBORS);
			
	index_ptr->knnSearch(mFlannFeaturesTest, indices, dists, TOTAL_NEIGHBORS, flann::SearchParams(128));

	//
	// 2d-3d correspondance
	//
	std::map< uint32_t, std::pair< uint32_t, float > > corr_3D_to_2D; //map for 3d point and corresponding 2d feature and dist (for lowest dist)
	std::map< uint32_t, std::pair< uint32_t, float > >::iterator map_it_3D;


	corr_3D_to_2D.clear();

	uint32_t ratio_passed = 0;
	for( size_t j=0; j<nb_keypoints; j++ ){
		uint32_t nn = indices[j][0];
		uint32_t nn2 = indices[j][1];
		// compute the SIFT-ratio
		float ratio = dists[j][0]/dists[j][1];
		

		if( ratio < 0.7 ){
			ratio_passed++;
			
			// we found one, so we need check for mutual nearest neighbors
			map_it_3D = corr_3D_to_2D.find( nn );
			
			if( map_it_3D != corr_3D_to_2D.end() ){
				if( map_it_3D->second.second > dists[j][0] ){
					map_it_3D->second.first = j;
					map_it_3D->second.second = dists[j][0];
				}
			}
			else{
				corr_3D_to_2D.insert( std::make_pair( nn, std::make_pair( j, dists[j][0] ) ) );
			}
		}
	}
	
	for( map_it_3D = corr_3D_to_2D.begin(); map_it_3D != corr_3D_to_2D.end(); ++map_it_3D ){
		struct FeaturePoint kp_data;
		kp_data.feature_x = keypoints_test[map_it_3D->second.first].pt.x;
		kp_data.feature_y = keypoints_test[map_it_3D->second.first].pt.y;

		int id_3d=map_2d3d[map_it_3D->first];				
		kp_data.point_x = feature_infos[id_3d].point.x;
		kp_data.point_y = feature_infos[id_3d].point.y;
		kp_data.point_z = feature_infos[id_3d].point.z;

		bool flag = 0;
		for(size_t i=0; i < test_kp_data_vec.size(); i++){
			FeaturePoint kp_data_existing = test_kp_data_vec[i];
			if(kp_data_existing.feature_x == kp_data.feature_x && kp_data_existing.feature_y == kp_data.feature_y){
				flag = 1;
				break;
			}
		}
		if(flag == 1){
			continue;
		}

		points_first.push_back(cv::Point2f(keypoints_test[map_it_3D->second.first].pt.x, keypoints_test[map_it_3D->second.first].pt.y));
		test_kp_data_vec.push_back(kp_data);

	}			

	free(features_test);
	delete[] indices.ptr();
	delete[] dists.ptr();

	descriptors_test.release();

}


void fill_correspondence_ratiotested(std::vector<cv::KeyPoint> &keypoints_test, const flann::Matrix<int>& indices, const flann::Matrix<float> &dists){

	std::map< uint32_t, std::pair< uint32_t, float > > corr_3D_to_2D; //{ref_kp, (test_kp, distance)} 
	corr_3D_to_2D.clear();
	
	uint32_t ratio_passed = 0;
	for( size_t i=0; i<keypoints_test.size(); i++ ){
		uint32_t nn = indices[i][0];
		uint32_t nn2 = indices[i][1];
		// compute the SIFT-ratio
		float ratio = dists[i][0]/dists[i][1];

		
		if( ratio < 0.7 ){

			//for debug only
			float feature_x = keypoints_test[i].pt.x;
			float feature_y = keypoints_test[i].pt.y;
			float proj_error = get_projection_error(feature_x, feature_y, i, 0, indices);
			
			if(debug){
				if( pthread_mutex_lock(&mutex_debug) != 0 ) perror("write mutex lock failed");			
				ofs_debug << "DEBUG: " << frame_counter << " " << i << " " << 0 << " " << proj_error << " " <<  dists[i][0] << " " << std::endl;
				if( pthread_mutex_unlock(&mutex_debug) != 0 ) perror("write mutex unlock failed");
			}
			//end: for debug only

			ratio_passed++;
			
			// we found one, so we need check for mutual nearest neighbors
			std::map< uint32_t, std::pair< uint32_t, float > >::iterator it = corr_3D_to_2D.find( nn );
			
			if( it != corr_3D_to_2D.end() ){
				if( it->second.second > dists[i][0] ){
					it->second.first = i;
					it->second.second = dists[i][0];
				}
			}
			else{
				corr_3D_to_2D.insert( std::make_pair( nn, std::make_pair( i, dists[i][0] ) ) );
			}
		}
	}
	
			
	for( std::map< uint32_t, std::pair< uint32_t, float > >::const_iterator it = corr_3D_to_2D.begin(); it != corr_3D_to_2D.end(); ++it ){
		struct FeaturePoint kp_data = {-1, -1, -1, -1, -1, -1, -1, -1};
		kp_data.feature_x = keypoints_test[it->second.first].pt.x;
		kp_data.feature_y = keypoints_test[it->second.first].pt.y;
		
		int id_3d=map_2d3d[it->first];				
		kp_data.point_x = feature_infos[id_3d].point.x;
		kp_data.point_y = feature_infos[id_3d].point.y;
		kp_data.point_z = feature_infos[id_3d].point.z;
		
		kp_data.ratio = dists[it->second.first][0]/dists[it->second.first][1];
		
		if(!is_existing_keypoint_xy(kp_data)){
			if( pthread_mutex_lock(&mutex_write) != 0 ) perror("write mutex lock failed");
			points_first.push_back(cv::Point2f(keypoints_test[it->second.first].pt.x, keypoints_test[it->second.first].pt.y));
			test_kp_data_vec.push_back(kp_data);
			if( pthread_mutex_unlock(&mutex_write) != 0 ) perror("write mutex unlock failed");
		}

	}			

}



void fill_correspondence_constrained(std::vector<cv::KeyPoint> &keypoints_test, const flann::Matrix<int>& indices, const flann::Matrix<float> &dists){

	
	std::map< uint32_t, MatchInfo > neighbor_map; //{test_kp, (ref_kp, distance, projerror)} 
	std::vector<MatchInfo> test_kps_neighbor_data_vec;
	test_kps_neighbor_data_vec.resize(keypoints_test.size());

	
	for( size_t i=0; i<keypoints_test.size(); i++ ){
		
		float feature_x = keypoints_test[i].pt.x;
		float feature_y = keypoints_test[i].pt.y;
		
		MatchInfo info = {-1, std::numeric_limits<float>::infinity(), std::numeric_limits<float>::infinity()};
		test_kps_neighbor_data_vec[i] = info;

		for(size_t j=0; j<TOTAL_NEIGHBORS; j++){
			
			float proj_error = get_projection_error(feature_x, feature_y, i, j, indices);
			
			if(debug){
				if( pthread_mutex_lock(&mutex_debug) != 0 ) perror("write mutex lock failed");			
				ofs_debug << "DEBUG: " << frame_counter << " " << i << " " << j << " " << proj_error << " " <<  dists[i][j] << " " << std::endl;
				if( pthread_mutex_unlock(&mutex_debug) != 0 ) perror("write mutex unlock failed");
			}

			if(proj_error < MAX_SQUARED_ERROR_BACKPROJECTION && proj_error > 0){ 

				if(test_kps_neighbor_data_vec[i].distance > dists[i][j] ){
					test_kps_neighbor_data_vec[i].index = j;
					test_kps_neighbor_data_vec[i].distance = dists[i][j];
					test_kps_neighbor_data_vec[i].proj_error = proj_error;
				}
				
			}
			
		}
		
	}


	for(size_t i=0; i<test_kps_neighbor_data_vec.size(); i++){
		std::cout << "info: " << i << " " << test_kps_neighbor_data_vec[i].index << " " << test_kps_neighbor_data_vec[i].distance << " " << test_kps_neighbor_data_vec[i].proj_error << std::endl;
	}
	

	std::map< uint32_t, MatchInfo > corr_3D_to_2D; //{ref_kp, (test_kp, distance, proj_error)} 

	for( size_t i=0; i<test_kps_neighbor_data_vec.size(); i++ ){
		
		MatchInfo neighbor_data = test_kps_neighbor_data_vec[i];
		if(neighbor_data.index == -1){ //there was no neighbor that satisfied the projection error 
			continue;
		}
		
		std::map< uint32_t, MatchInfo >::iterator it = corr_3D_to_2D.find( neighbor_data.index );
		
		if( it != corr_3D_to_2D.end() ){
			if( it->second.distance > neighbor_data.distance ){
				it->second.index = i;
				it->second.distance = neighbor_data.distance;
				it->second.proj_error = neighbor_data.proj_error;
			}
		}
		else{
			MatchInfo test_kp_info ={i, neighbor_data.distance, neighbor_data.proj_error};
			corr_3D_to_2D.insert( std::make_pair( neighbor_data.index, test_kp_info ) );
		}
	}
	

	for( std::map< uint32_t, MatchInfo >::const_iterator it = corr_3D_to_2D.begin(); it != corr_3D_to_2D.end(); ++it ){
		struct FeaturePoint kp_data = {-1, -1, -1, -1, -1, -1, -1, -1};
		kp_data.feature_x = keypoints_test[it->second.index].pt.x;
		kp_data.feature_y = keypoints_test[it->second.index].pt.y;
		
		int id_3d=map_2d3d[it->first];				
		kp_data.point_x = feature_infos[id_3d].point.x;
		kp_data.point_y = feature_infos[id_3d].point.y;
		kp_data.point_z = feature_infos[id_3d].point.z;
			
		//kp_data.ratio = dists[it->second.first][0]/dists[it->second.first][1];
		MatchInfo test_kp_info = it->second;
		kp_data.feature_distance = test_kp_info.distance;                                                                                                                       
		kp_data.projection_error = test_kp_info.proj_error;     
			
		if(!is_existing_keypoint_xy(kp_data)){
			if( pthread_mutex_lock(&mutex_write) != 0 ) perror("write mutex lock failed");
			points_first.push_back(cv::Point2f(keypoints_test[it->second.index].pt.x, keypoints_test[it->second.index].pt.y));
			test_kp_data_vec.push_back(kp_data);
			if( pthread_mutex_unlock(&mutex_write) != 0 ) perror("write mutex unlock failed");
		}
		
	}			
}

void *match_features_subimage(void *){

	while(true){
		struct ThreadData data = queue.remove();

		std::vector<cv::KeyPoint> keypoints_test;
		cv::Mat descriptors_test;
	
		pdetector->detect(data.image, keypoints_test);
		pextractor->compute(data.image, keypoints_test, descriptors_test);


		uint32_t nb_keypoints = (uint32_t) keypoints_test.size();		
	
		float* features_test = (float*)malloc(nb_keypoints * 128 * sizeof(float));
	
		for(size_t j=0; j<nb_keypoints; j++){
			keypoints_test[j].pt.x += data.top;
			keypoints_test[j].pt.y += data.left;
		
			for( uint32_t k=0; k<128; ++k ){
				features_test[j*128+k] = descriptors_test.at<float>(j,k);
			}
		}

	
		flann::Matrix< float > mFlannFeaturesTest(features_test, nb_keypoints, 128);


		flann::Matrix<int> indices(new int[nb_keypoints*TOTAL_NEIGHBORS], nb_keypoints, TOTAL_NEIGHBORS); 
		flann::Matrix<float> dists(new float[nb_keypoints*TOTAL_NEIGHBORS], nb_keypoints, TOTAL_NEIGHBORS);
			
		index_ptr->knnSearch(mFlannFeaturesTest, indices, dists, TOTAL_NEIGHBORS, flann::SearchParams(128));

		//
		// 2d-3d correspondance
		//
		std::map< uint32_t, std::pair< uint32_t, float > > corr_3D_to_2D; //map for 3d point and corresponding 2d feature and dist (for lowest dist)
		std::map< uint32_t, std::pair< uint32_t, float > >::iterator map_it_3D;


		if(computation_type=="ratiotested"){
			fill_correspondence_ratiotested(keypoints_test, indices, dists);
		}else if(computation_type=="constrained"){
			fill_correspondence_constrained(keypoints_test, indices, dists);
		}else{
			std::cout << "Invalid computation type" << std::endl;
			exit(1);
		}


		free(features_test);
		delete[] indices.ptr();
		delete[] dists.ptr();

		descriptors_test.release();
	}
}



void track_features(int &tracker_given_count, int &tracker_success_count){
	std::cout << "inside track features " << points_first.size() << std::endl;
	

	if(points_first.size() == 0){
		std::cerr << "zero features to track!" << std::endl;
		return;
	}

	tracker_given_count=points_first.size();

	std::vector<uchar> status;
	std::vector<float> err;
   
	Timer timer;
	timer.Init();	
	timer.Start();
	cv::calcOpticalFlowPyrLK(prevGray, gray, points_first, points_second, status, err, winSize, 3, termcrit, 0, 0.001);
	timer.Stop();
	float opt_flow_time = timer.GetElapsedTime();
	std::cout << "opt flow time = " << opt_flow_time << std::endl;


	timer.Start();
	std::cout << "size of points_first=" << points_first.size() << std::endl;
	
	std::vector<cv::Point2f> points1, points2;


	int i, k;
	if( pthread_mutex_lock(&mutex_write) != 0 ) perror("write mutex lock failed"); 
	for( i = k = 0; i < points_second.size(); i++ ){
		if( !status[i] )
			continue;
		
		test_kp_data_vec[k].feature_x = points_second[i].x;
		test_kp_data_vec[k].feature_y = points_second[i].y;
		test_kp_data_vec[k].point_x = test_kp_data_vec[i].point_x;
		test_kp_data_vec[k].point_y = test_kp_data_vec[i].point_y;
		test_kp_data_vec[k].point_z = test_kp_data_vec[i].point_z;
		
		points_second[k] = points_second[i];
		
		k++;
		cv::circle( image, points_second[i], 3, cv::Scalar(0,255,0), -1, 8);
	}
	
	test_kp_data_vec.resize(k);
	points_second.resize(k);

	tracker_success_count = points_second.size();
		
	std::swap(points_second, points_first);
	if( pthread_mutex_unlock(&mutex_write) != 0 ) perror("write mutex unlock failed");

	std::cout << "points_second size= " << points_second.size() << std::endl;

	cv::swap(prevGray, gray);

	

#ifdef SHOW_FLOW_SCREEN			
	cv::namedWindow( "flow", cv::WINDOW_NORMAL );
	cv::imshow("flow", image);

	char c = (char)cv::waitKey(10);
	if( c == 27 ) exit(0);
#endif



	timer.Stop();
}




Util::Math::ProjMatrix ransac_pose(int &inlier_count){
	//
	// do the pose verification using RANSAC
	//
	std::vector< float > c2D, c3D;
	c2D.clear();
	c3D.clear();
	
	if(computation_type == "constrained"){
		std::sort(test_kp_data_vec.begin(), test_kp_data_vec.end(), compareByFeatureDistance);
		

		std::cout << "kp_data size " << test_kp_data_vec.size() << std::endl;
		for(int i=0;  i<1000 && i<test_kp_data_vec.size() ; i++){ //TODO: hard codes max limit of 1000, parameterized
			//push centered points
			FeaturePoint kp_data = test_kp_data_vec[i];
			
			c2D.push_back(kp_data.feature_x - (img_width-1.0)/2.0f);
			c2D.push_back((img_height-1.0)/2.0f - kp_data.feature_y);
			
			c3D.push_back(kp_data.point_x);
			c3D.push_back(kp_data.point_y);
			c3D.push_back(kp_data.point_z);
			
			std::cout << "kp_data " << kp_data.ratio << " " << kp_data.feature_distance << " " << kp_data.projection_error << std::endl;
		}
	}else if(computation_type=="ratiotested"){

		std::cout << "kp_data size " << test_kp_data_vec.size() << std::endl;
		for(int i=0;  i<test_kp_data_vec.size() ; i++){
			//push centered points
			FeaturePoint kp_data = test_kp_data_vec[i];
			
			c2D.push_back(kp_data.feature_x - (img_width-1.0)/2.0f);
			c2D.push_back((img_height-1.0)/2.0f - kp_data.feature_y);
			
			c3D.push_back(kp_data.point_x);
			c3D.push_back(kp_data.point_y);
			c3D.push_back(kp_data.point_z);
			
			std::cout << "kp_data " << kp_data.ratio << " " << kp_data.feature_distance << " " << kp_data.projection_error << std::endl;
		}
		
	}


	uint32_t nb_corr = c2D.size() / 2;
	//uint32_t minimal_RANSAC_solution = 12;
	uint32_t minimal_RANSAC_solution = 3;
	float min_inlier = 0.0f;

	RANSAC::computation_type = P6pt;
	RANSAC::stop_after_n_secs = true;
	RANSAC::max_time = 60.0;
	RANSAC::error = 30.0f; // for P6pt this is the SQUARED reprojection error in pixels

		
	std::cout << " applying RANSAC on " << nb_corr << std::endl;
	
	ransac_solver.set_projection_matrix(proj_matrix_prev);
	ransac_solver.apply_RANSAC( c2D, c3D, nb_corr, std::min( std::max( float( minimal_RANSAC_solution ) / float( nb_corr ), min_inlier ), 1.0f ) ); 


	// get the solution from RANSAC    
	std::vector< uint32_t > inliers;
    
	inliers.assign( ransac_solver.get_inliers().begin(), ransac_solver.get_inliers().end()  );
	inlier_count = ransac_solver.get_number_of_inliers();

	Util::Math::ProjMatrix proj_matrix = ransac_solver.get_projection_matrix();

	if(debug){
		if( pthread_mutex_lock(&mutex_debug) != 0 ) perror("write mutex lock failed");			
		ofs_debug << "ransac proj matrix:" <<proj_matrix << std::endl;
		if( pthread_mutex_unlock(&mutex_debug) != 0 ) perror("write mutex unlock failed");
	}

	proj_matrix_prev = ransac_solver.get_projection_matrix();


	// decompose the projection matrix
	Util::Math::Matrix3x3 Rot, K;
	proj_matrix.decompose( K, Rot );
	proj_matrix.computeInverse();
	proj_matrix.computeCenter();
	//std::cout << " camera calibration: " << K << std::endl;
	//std::cout << " camera rotation: " << Rot << std::endl;
	//std::cout << " camera position: " << proj_matrix.m_center << std::endl;   
	//std::cout << proj_matrix.m_center << std::endl;

	return proj_matrix;

}


void usage(){
	printf("Usage: pose_estimator_subdevided\n");
	printf("\t-b bundle info file produced by Bundle2Info\n");
	printf("\t-k list_keys.txt \n");
	printf("\t-w image_width \n");
	printf("\t-h image_height \n");
	printf("\t-o output_filename \n");
	printf("\nFlags:");
	printf("\t[-g]\n");
	printf("\n");
}




void process_args(int argc, char** argv){
	char const *optString = "-c:-b:-k:-w:-h:-s:-t:-d:-o:-v:";
	int opt = getopt( argc, argv, optString );

	while( opt != -1 ) {
		switch( opt ) {                  

		case 'c':
			computation_type = optarg;
			break;

		case 'b':
			info_file = optarg;
			break;

		case 'k':
			list_file = optarg;
			break;

		case 'w':
			img_width = atoi(optarg);
			break;

		case 'h':
			img_height = atoi(optarg);
			break;

		case 's':
			subdivision = atoi(optarg);
			break;

		case 't':
			tracking_count = atoi(optarg);
			break;

		case 'd':
			calibration_distance = atof(optarg);
			break;

		case 'o':
			out_filename = optarg;
			break;

		case 'v':
			vis_dirname = optarg;
			break;

		default:
			break;
		}
		opt = getopt( argc, argv, optString );
	}

}

int main(int argc, char **argv){
	if(argc == 1 ){
		usage();
		exit(1);
	}

	cv::initModule_nonfree();

	process_args(argc, argv);
	std::cout << calibration_distance << std::endl;
	

	if(debug) ofs_debug.open(debug_filename.c_str());

	cv::KalmanFilter KF;         // instantiate Kalman Filter
	int nStates = 18;            // the number of states
	int nMeasurements = 6;       // the number of measured states
	int nInputs = 0;             // the number of control actions
	double dt = 0.125;  //TODO: what should be this value???

	initKalmanFilter(KF, nStates, nMeasurements, nInputs, dt); 
	cv::Mat measurements(nMeasurements, 1, CV_64F); measurements.setTo(cv::Scalar(0));
	bool good_measurement = false;


	float x_step_subimage = img_width/subdivision;
	float y_step_subimage = img_height/subdivision;

	std::cout << img_width << " " << img_height << " " << subdivision << " " << x_step_subimage << " " << y_step_subimage << std::endl;

	pdetector = cv::FeatureDetector::create( "SIFT" ); 
	pextractor = cv::DescriptorExtractor::create( "SIFT" ); 

	//load the bundler info data
	index_ptr = new flann::Index< flann::L2<float> >(load_bundler_info(info_file));

    ////////////////////////////////////////////////////////////////////////////////////////////////

	std::ofstream ofs;
	ofs.open(out_filename.c_str());
	ofs << "Frame tracked_points track_time ransac_time total_time pos-x pos-y pos-z" << std::endl;


	test_kp_data_vec.clear();

	std::ifstream file(list_file.c_str());
	cv::Mat image_subdevided;


	Timer timer;
	timer.Init();	

	double track_time = -1;
	double ransac_time = -1;
	double frame_time = -1;

	Timer timer_frame;
	timer_frame.Init();

	for(int i=0; i<TOTAL_THREADS; i++){
		pthread_t thread;
		int ret = pthread_create(&thread, NULL, match_features_subimage, NULL);
		if(ret != 0){ 
			std::cout << "Thread creation failed " << ret << " " << std::endl;
			perror("pthread_create");
		}
	}

	bool is_first_frame=true;

	while(true){
		std::getline(file, key_filename);
		if(key_filename == ""){
			std::cout << "Filename empty or done processing all files" << std::endl; 
			exit(0);
		}
		


		std::string jpg_filename = key_filename;
		jpg_filename.replace(key_filename.find(".key"), 4, ".jpg");
				
		image = cv::imread(jpg_filename);
		if (!image.data){std::cout << "Image file can't be read!" << std::endl; return -1;}

		if(is_first_frame){
			process_first_frame(image);
			is_first_frame = false;
			continue;
		}



		image_subdevided = image.clone();
		
		cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
		
		if(prevGray.empty()){
			gray.copyTo(prevGray);
		}

		timer_frame.Start();

		if(frame_counter % tracking_count == 0){

			for(int i=0; i<subdivision; i++){
				for(int j=0; j<subdivision; j++){
					
					int x0 = i*x_step_subimage;
					int y0 = j*y_step_subimage;
					int x1 = x0 + x_step_subimage;
					int y1 = y0 + y_step_subimage;
					std::cout << x0 << " - " << y0 << " - " << x1 << " - " << y1 << std::endl;
					
					cv::Mat subimage = cv::Mat(image_subdevided, cv::Rect(x0, y0, x1-x0, y1-y0)).clone();
					
					struct ThreadData q_data;
					q_data.image = subimage;
					q_data.top = x0;
					q_data.left = y0;
					queue.add(q_data);
	
				}
			}

		}


		int tracker_given_count;
		int tracker_success_count;
		timer.Start();
		track_features(tracker_given_count, tracker_success_count);
		timer.Stop();
		track_time = timer.GetElapsedTime();

		
		int inlier_count;
		timer.Start();
		Util::Math::ProjMatrix proj_matrix = ransac_pose(inlier_count);
		timer.Stop();
		ransac_time = timer.GetElapsedTime();
				
		timer_frame.Stop();
		frame_time = timer_frame.GetElapsedTime();

		// decompose the projection matrix
		Util::Math::Matrix3x3 Rot, K;
		proj_matrix.decompose( K, Rot );
		proj_matrix.computeInverse();
		proj_matrix.computeCenter();
		std::cout << " camera calibration: " << K << std::endl;
		std::cout << " camera rotation: " << Rot << std::endl;
		std::cout << " camera position: " << proj_matrix.m_center << std::endl;
    
		std::cout << proj_matrix.m_center[0] << " " << proj_matrix.m_center[1] << " " << proj_matrix.m_center[2] << std::endl;


		cv::Mat translation_measured(3, 1, CV_64F);
		translation_measured.at<double>(0,0) = proj_matrix.m_center[0];
		translation_measured.at<double>(0,1) = proj_matrix.m_center[1];
		translation_measured.at<double>(0,2) = proj_matrix.m_center[2];


		// Get the measured rotation
		cv::Mat rotation_measured(3, 3, CV_64F);
		rotation_measured.at<double>(0,0) = Rot(0, 0);
		rotation_measured.at<double>(0,1) = Rot(0, 1);
		rotation_measured.at<double>(0,2) = Rot(0, 2);
		rotation_measured.at<double>(1,0) = Rot(1, 0);
		rotation_measured.at<double>(1,1) = Rot(1, 1);
		rotation_measured.at<double>(1,2) = Rot(1, 2);
		rotation_measured.at<double>(2,0) = Rot(2, 0);
		rotation_measured.at<double>(2,1) = Rot(2, 1);
		rotation_measured.at<double>(2,2) = Rot(2, 2);


		// fill the measurements vector
		fillMeasurements(measurements, translation_measured, rotation_measured);


		// Instantiate estimated translation and rotation
		cv::Mat translation_estimated(3, 1, CV_64F);
		cv::Mat rotation_estimated(3, 3, CV_64F);

		// update the Kalman filter with good measurements
		updateKalmanFilter( KF, measurements, translation_estimated, rotation_estimated, ransac_solver.get_number_of_inliers());

		std::cout << translation_measured << " " << translation_estimated << std::endl;

		
		std::cout << key_filename << " " << points_second.size() << " " << track_time << " " << ransac_time << " " << frame_time << " " 
		<< proj_matrix.m_center << std::endl;

		ofs << key_filename << " " << points_second.size() << " "<< inlier_count << " " << tracker_given_count << " " << tracker_success_count << " " << track_time << " " << ransac_time << " " << frame_time << " " << \
			proj_matrix.m_center << " " << translation_estimated.at<double>(0,0) << " " << translation_estimated.at<double>(0,1) << " " << translation_estimated.at<double>(0,2)<< std::endl;

		frame_counter++;

		image.release();
		image_subdevided.release();
		std::cout << "is empty image " << image.empty() << std::endl;
		std::cout << "is empty image_subdevided " << image_subdevided.empty() << std::endl;

	}

	ofs.close();

	delete index_ptr;
	
}
