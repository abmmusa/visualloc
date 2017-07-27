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



#include "spatialfunc.hh"
#include <cmath>

bool same_coords(double a_lat, double a_lon, double b_lat, double b_lon)
{
	if (a_lat == b_lat && a_lon == b_lon)
		return true;
	else
		return false;
}


double radians(double deg)
{
	return deg*PI/180.0;
}



float distance(double a_lat, double a_lon, double b_lat, double b_lon)
{
	if (same_coords(a_lat, a_lon, b_lat, b_lon)){
		return 0.0;
	}

	double dLat = radians(b_lat - a_lat);
	double dLon = radians(b_lon - a_lon);
    
	double a = sin(dLat/2.0) * sin(dLat/2.0) + cos(radians(a_lat)) * cos(radians(b_lat)) * sin(dLon/2.0) * sin(dLon/2.0);
    
	double c = 2.0 * atan2(sqrt(a), sqrt(1 - a));
	double d = EARTH_RADIUS * c;
    
	return d;
}
