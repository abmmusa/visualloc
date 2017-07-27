import sys



if __name__=="__main__":
    list_filename=sys.argv[1]
    matches_filename=sys.argv[2]

    print list_filename, matches_filename

    #read the list_filename and build a map with filename and index
    image_index_map={}
    list_file=open(list_filename, "r")
    images=list_file.readlines()

    index_counter=0
    for image_info in images:
        image=image_info.split(" ")[0]
        image_index_map[index_counter]=image
        index_counter=index_counter+1
        

    list_file.close()
    #print image_index_map

    matches_file=open(matches_filename, "r")

    while True:
        frames_line=matches_file.readline()
        if not frames_line:
            break

        frames=tuple(map(int, frames_line.split(" ")))        
        count=int(matches_file.readline())
        
        print image_index_map[frames[0]], image_index_map[frames[1]], count

        all_matches=[]
        for i in range(count):
            match_indices=tuple(map(int, matches_file.readline().split(" ")))
            all_matches.append(match_indices)
         
        for match_indices in all_matches:
            sys.stdout.write(str(match_indices[0])+" ")
        print
        
        for match_indices in all_matches:
            sys.stdout.write(str(match_indices[1])+" ")
        print

