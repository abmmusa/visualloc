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



#include <opencv/cv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/video/tracking.hpp>
#include <opencv2/features2d/features2d.hpp>
#include "opencv2/nonfree/features2d.hpp"
#include <opencv2/nonfree/nonfree.hpp>



#include "kalman.hh"


cv::Mat measurementNoiseBasis(6,6,CV_64F);

cv::Mat rot2euler(const cv::Mat & rotationMatrix)
{
	cv::Mat euler(3,1,CV_64F);

	double m00 = rotationMatrix.at<double>(0,0);
	double m02 = rotationMatrix.at<double>(0,2);
	double m10 = rotationMatrix.at<double>(1,0);
	double m11 = rotationMatrix.at<double>(1,1);
	double m12 = rotationMatrix.at<double>(1,2);
	double m20 = rotationMatrix.at<double>(2,0);
	double m22 = rotationMatrix.at<double>(2,2);

	double x, y, z;

	// Assuming the angles are in radians.
	if (m10 > 0.998) { // singularity at north pole
		x = 0;
		y = CV_PI/2;
		z = atan2(m02,m22);
	}
	else if (m10 < -0.998) { // singularity at south pole
		x = 0;
		y = -CV_PI/2;
		z = atan2(m02,m22);
	}
	else
		{
			x = atan2(-m12,m11);
			y = asin(m10);
			z = atan2(-m20,m00);
		}

	euler.at<double>(0) = x;
	euler.at<double>(1) = y;
	euler.at<double>(2) = z;

	return euler;
}

// Converts a given Euler angles to Rotation Matrix
cv::Mat euler2rot(const cv::Mat & euler)
{
	cv::Mat rotationMatrix(3,3,CV_64F);

	double x = euler.at<double>(0);
	double y = euler.at<double>(1);
	double z = euler.at<double>(2);

	// Assuming the angles are in radians.
	double ch = cos(z);
	double sh = sin(z);
	double ca = cos(y);
	double sa = sin(y);
	double cb = cos(x);
	double sb = sin(x);

	double m00, m01, m02, m10, m11, m12, m20, m21, m22;

	m00 = ch * ca;
	m01 = sh*sb - ch*sa*cb;
	m02 = ch*sa*sb + sh*cb;
	m10 = sa;
	m11 = ca*cb;
	m12 = -ca*sb;
	m20 = -sh*ca;
	m21 = sh*sa*cb + ch*sb;
	m22 = -sh*sa*sb + ch*cb;

	rotationMatrix.at<double>(0,0) = m00;
	rotationMatrix.at<double>(0,1) = m01;
	rotationMatrix.at<double>(0,2) = m02;
	rotationMatrix.at<double>(1,0) = m10;
	rotationMatrix.at<double>(1,1) = m11;
	rotationMatrix.at<double>(1,2) = m12;
	rotationMatrix.at<double>(2,0) = m20;
	rotationMatrix.at<double>(2,1) = m21;
	rotationMatrix.at<double>(2,2) = m22;

	return rotationMatrix;
}



void initKalmanFilter(cv::KalmanFilter &KF, int nStates, int nMeasurements, int nInputs, double dt)
{

	KF.init(nStates, nMeasurements, nInputs, CV_64F);                 // init Kalman Filter

	setIdentity(KF.errorCovPost, cv::Scalar::all(10));             // error covariance

	//setIdentity(KF.processNoiseCov, cv::Scalar::all(1e-5));       // set process noise
	/** process noise is all zeroes, except for the diagonal. We only have process noise in the acceleration terms. **/

	KF.processNoiseCov.at<double>(0,0) = 0.0;
	KF.processNoiseCov.at<double>(1,1) = 0.0;
	KF.processNoiseCov.at<double>(2,2) = 0.0;
	KF.processNoiseCov.at<double>(3,3) = 0.0;
	KF.processNoiseCov.at<double>(4,4) = 0.0;
	KF.processNoiseCov.at<double>(5,5) = 0.0;
	KF.processNoiseCov.at<double>(6,6) = 0.25;
	KF.processNoiseCov.at<double>(7,7) = 0.1;
	KF.processNoiseCov.at<double>(8,8) = 0.5;
	KF.processNoiseCov.at<double>(9,9) = 0.0;
	KF.processNoiseCov.at<double>(10,10) = 0.0;
	KF.processNoiseCov.at<double>(11,11) = 0.0;
	KF.processNoiseCov.at<double>(12,12) = 0.0;
	KF.processNoiseCov.at<double>(13,13) = 0.0;
	KF.processNoiseCov.at<double>(14,14) = 0.0;
	KF.processNoiseCov.at<double>(15,15) = 0.1;
	KF.processNoiseCov.at<double>(16,16) = 0.1;
	KF.processNoiseCov.at<double>(17,17) = 0.1;


	//setIdentity(KF.measurementNoiseCov, cv::Scalar::all(1e-2));   // set measurement noise
	/** measurement noise covariance. all zeroes, except the diagonal - hoping our noise isn't correlated. */

	// this is the gaussian noise we expect outside of outliers. outliers must be handled separately.
	measurementNoiseBasis.at<double>(0,0) = 0.5;
	measurementNoiseBasis.at<double>(1,1) = 0.5;
	measurementNoiseBasis.at<double>(2,2) = 0.5;
	measurementNoiseBasis.at<double>(3,3) = 0.1;
	measurementNoiseBasis.at<double>(4,4) = 0.1;
	measurementNoiseBasis.at<double>(5,5) = 0.1;
	KF.measurementNoiseCov=measurementNoiseBasis;

	/** DYNAMIC MODEL **/

	//  [1 0 0 dt  0  0 dt2   0   0 0 0 0  0  0  0   0   0   0]
	//  [0 1 0  0 dt  0   0 dt2   0 0 0 0  0  0  0   0   0   0]
	//  [0 0 1  0  0 dt   0   0 dt2 0 0 0  0  0  0   0   0   0]
	//  [0 0 0  1  0  0  dt   0   0 0 0 0  0  0  0   0   0   0]
	//  [0 0 0  0  1  0   0  dt   0 0 0 0  0  0  0   0   0   0]
	//  [0 0 0  0  0  1   0   0  dt 0 0 0  0  0  0   0   0   0]
	//  [0 0 0  0  0  0   1   0   0 0 0 0  0  0  0   0   0   0]
	//  [0 0 0  0  0  0   0   1   0 0 0 0  0  0  0   0   0   0]
	//  [0 0 0  0  0  0   0   0   1 0 0 0  0  0  0   0   0   0]
	//  [0 0 0  0  0  0   0   0   0 1 0 0 dt  0  0 dt2   0   0]
	//  [0 0 0  0  0  0   0   0   0 0 1 0  0 dt  0   0 dt2   0]
	//  [0 0 0  0  0  0   0   0   0 0 0 1  0  0 dt   0   0 dt2]
	//  [0 0 0  0  0  0   0   0   0 0 0 0  1  0  0  dt   0   0]
	//  [0 0 0  0  0  0   0   0   0 0 0 0  0  1  0   0  dt   0]
	//  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  1   0   0  dt]
	//  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  0   1   0   0]
	//  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  0   0   1   0]
	//  [0 0 0  0  0  0   0   0   0 0 0 0  0  0  0   0   0   1]

	// position
	KF.transitionMatrix.at<double>(0,3) = dt;
	KF.transitionMatrix.at<double>(1,4) = dt;
	KF.transitionMatrix.at<double>(2,5) = dt;
	KF.transitionMatrix.at<double>(3,6) = dt;
	KF.transitionMatrix.at<double>(4,7) = dt;
	KF.transitionMatrix.at<double>(5,8) = dt;
	KF.transitionMatrix.at<double>(0,6) = 0.5*pow(dt,2);
	KF.transitionMatrix.at<double>(1,7) = 0.5*pow(dt,2);
	KF.transitionMatrix.at<double>(2,8) = 0.5*pow(dt,2);

	// orientation
	KF.transitionMatrix.at<double>(9,12) = dt;
	KF.transitionMatrix.at<double>(10,13) = dt;
	KF.transitionMatrix.at<double>(11,14) = dt;
	KF.transitionMatrix.at<double>(12,15) = dt;
	KF.transitionMatrix.at<double>(13,16) = dt;
	KF.transitionMatrix.at<double>(14,17) = dt;
	KF.transitionMatrix.at<double>(9,15) = 0.5*pow(dt,2);
	KF.transitionMatrix.at<double>(10,16) = 0.5*pow(dt,2);
	KF.transitionMatrix.at<double>(11,17) = 0.5*pow(dt,2);

	/** MEASUREMENT MODEL **/

	//  [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
	//  [0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
	//  [0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
	//  [0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0]
	//  [0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0]
	//  [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0]

	KF.measurementMatrix.at<double>(0,0) = 1;  // x
	KF.measurementMatrix.at<double>(1,1) = 1;  // y
	KF.measurementMatrix.at<double>(2,2) = 1;  // z
	KF.measurementMatrix.at<double>(3,9) = 1;  // roll
	KF.measurementMatrix.at<double>(4,10) = 1; // pitch
	KF.measurementMatrix.at<double>(5,11) = 1; // yaw

}

/**********************************************************************************************************/
void updateKalmanFilter( cv::KalmanFilter &KF, cv::Mat &measurement,
                         cv::Mat &translation_estimated, cv::Mat &rotation_estimated, int inlier_count )
{

	// First predict, to update the internal statePre variable
	cv::Mat prediction = KF.predict();

	double zdiff=prediction.at<double>(2)-measurement.at<double>(2);
	double ydiff=prediction.at<double>(1)-measurement.at<double>(1);
	double xdiff=prediction.at<double>(0)-measurement.at<double>(0);
	double zCov = KF.errorCovPost.at<double>(2,2);
	double yCov = KF.errorCovPost.at<double>(1,1);
	double xCov = KF.errorCovPost.at<double>(0,0);
	cv::Mat estimated;

	// if the measurement falls outside of 4 standard deviations of the current a posteriori 
	// covariance estimate, then ignore this measurement. WARNING: this is pretty aggressive, 
	// may want to go with a much greater threshold if this causes filter to get stuck in one place

	if(abs(zdiff) < sqrt(zCov)*4 && 
		 abs(ydiff) < sqrt(yCov)*4 && 
		 abs(xdiff) < sqrt(xCov)*4) {
		// The "correct" phase that is going to use the predicted value and our measurement
		estimated = KF.correct(measurement);
	}
	else {
		estimated = prediction;
	}

	// Estimated translation
	translation_estimated.at<double>(0) = estimated.at<double>(0);
	translation_estimated.at<double>(1) = estimated.at<double>(1);
	translation_estimated.at<double>(2) = estimated.at<double>(2);
		
	// Estimated euler angles
	cv::Mat eulers_estimated(3, 1, CV_64F);
	eulers_estimated.at<double>(0) = estimated.at<double>(9);
	eulers_estimated.at<double>(1) = estimated.at<double>(10);
	eulers_estimated.at<double>(2) = estimated.at<double>(11);

	// Convert estimated quaternion to rotation matrix
	rotation_estimated = euler2rot(eulers_estimated);

}


/**********************************************************************************************************/
void fillMeasurements( cv::Mat &measurements,
                       const cv::Mat &translation_measured, const cv::Mat &rotation_measured)
{
	// Convert rotation matrix to euler angles
	cv::Mat measured_eulers(3, 1, CV_64F);
	measured_eulers = rot2euler(rotation_measured);

	// Set measurement to predict
	measurements.at<double>(0) = translation_measured.at<double>(0); // x
	measurements.at<double>(1) = translation_measured.at<double>(1); // y
	measurements.at<double>(2) = translation_measured.at<double>(2); // z
	measurements.at<double>(3) = measured_eulers.at<double>(0);      // roll
	measurements.at<double>(4) = measured_eulers.at<double>(1);      // pitch
	measurements.at<double>(5) = measured_eulers.at<double>(2);      // yaw
}
