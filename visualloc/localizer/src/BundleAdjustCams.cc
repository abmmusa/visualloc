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

#include "sfm/parse_bundler.hh"

#include "BundleAdjustCams.hh"


float calibration_distance = 100.0; // default

parse_bundler parser;

void adjust_bundler_cams(std::string info_filename, std::string out_filename){
	//
	// load the Bundler data
	//
	std::cout << "-> parsing the bundler output from " << info_filename << std::endl;
	//parser.load_from_binary( info_file.c_str(), 0 ); //0 is for bundle type if .info file is generated using Bundle2Info
	parser.load_from_binary( info_filename.c_str(), 1 ); //0 is for bundle type if .info file is generated using Bundle2Info, use 1 for having camera infos too
  
	//uint32_t nb_points = feature_infos.size();
	uint32_t nb_cameras = parser.get_number_of_cameras();
	uint32_t nb_points = parser.get_number_of_points();

	std::cout << nb_cameras << " " << nb_points << std::endl;
 
	std::cout << "--> done parsing the bundler output " << std::endl;


	/**
	 * reproject bundler output to fit real-world dimensions and orientation. 
	 **/

	const std::vector< bundler_camera > cameras = parser.get_cameras();
	std::cout << "found cameras " << cameras.size() << std::endl;

	const OpenMesh::Vec3d &origin = parser.get_cameras()[0].get_cam_position_d();
	const OpenMesh::Vec3d &destination = parser.get_cameras()[nb_cameras-1].get_cam_position_d();
	double dist = (destination-origin).norm();

	//for(uint32_t i=0; i<cameras.size(); i++){
	//	std::cout << parser.get_cameras()[i].get_cam_position_d() << std::endl;
	//}
	

	// angle rotated around y axis
	double y_angle = atan2(destination[0]-origin[0],destination[2]-origin[2]);
	// angle rotated around x axis
	double x_angle = atan2(destination[1]-origin[1],destination[2]-origin[2]); 

	std::cout << "origin: " << origin << " dest: " << destination << " distance:" << dist << " xangle: "<<x_angle<<" yangle: "<<y_angle<<std::endl;


	std::ofstream ofs;
	ofs.open(out_filename.c_str());

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

		//std::cout << parser.get_cameras()[i].id << std::endl;
		ofs << cam_pos[0] << " " << cam_pos[1] << " " << cam_pos[2] << std::endl;
	}

	ofs.close();

}



int main(int argc, char **argv){
	if(argc == 1 ){
		printf("Usage: BundleAdjustCams -b <bundle info file produced by Bundle2Info> -o <cam output file>");
		exit(1);
	}


	std::string info_filename = "";
	std::string out_filename = "";
	

	char const *optString = "-b:-d:-o:";
	int opt = getopt( argc, argv, optString );

	while( opt != -1 ) {
		switch( opt ) {                  

		case 'b':
			info_filename = optarg;
			break;

		case 'd':
			calibration_distance = atof(optarg);
			break;

		case 'o':
			out_filename = optarg;
			break;


		default:
			break;
		}
		opt = getopt( argc, argv, optString );
	}
	
	adjust_bundler_cams(info_filename, out_filename);

}
