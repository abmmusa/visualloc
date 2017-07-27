from pylibs import spatialfunclib
import math

class Location:
    def __init__(self, time=None, lat=None, lon=None, frame=None):
        self.time = time
        self.lat = lat
        self.lon = lon
        self.frame = frame

    def load_raw_location(self, raw_location):
        raw_location_components = raw_location.strip("\n").split(" ")
        
        self.time = float(raw_location_components[0])
        self.lat = float(raw_location_components[1])
        self.lon = float(raw_location_components[2])        
        self.frame = int(raw_location_components[3])        

    def __str__(self):
        return str(self.time) + " " + str(self.lat) + " " + str(self.lon) + " " + str(self.frame) 


class Interpolator:
    def __init__(self):
        pass
    
    def interpolate(self, trace):
        
        prev_location = None
        
        for raw_location in trace:
            curr_location = Location()
            curr_location.load_raw_location(raw_location)

            if prev_location is not None:
                
                distance = self._distance(curr_location, prev_location)
                timegap = curr_location.time - prev_location.time
                framegap = curr_location.frame - prev_location.frame
                bearing = self._path_bearing(prev_location, curr_location)

                for frame in range(int(prev_location.frame+1), int(curr_location.frame)):
                    distance_now = (distance/framegap)*(frame-prev_location.frame)
                    time_now = (prev_location.time+(timegap/framegap)*(frame-prev_location.frame))
                    dest_coord=spatialfunclib.destination_point(prev_location.lat, prev_location.lon, bearing, distance_now)
                    sys.stdout.write(str(time_now)+" "+str(dest_coord[0])+ " " + str(dest_coord[1]) + " " + str(frame) + "\n")

            sys.stdout.write(str(curr_location.time) +" " + str(curr_location.lat) + " " + str(curr_location.lon) + " " + str(curr_location.frame) + "\n")
            prev_location = curr_location
    
    
    def _distance(self, location1, location2):
        return spatialfunclib.distance(location1.lat, location1.lon, location2.lat, location2.lon)
    
    def _path_bearing(self, location1, location2):
        return spatialfunclib.path_bearing(location1.lat, location1.lon, location2.lat, location2.lon)

import sys, getopt
if __name__ == "__main__":
    
    (opts, args) = getopt.getopt(sys.argv[1:],"h")
    
    for o,a in opts:
        if o == "-h":
            print "Usage: <stdin> | python generate_interpolated_trace.py [-h]"
            exit()
    
    interpolator = Interpolator()
    interpolator.interpolate(sys.stdin)
