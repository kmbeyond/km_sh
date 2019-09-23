#!/bin/sh

-----Iterate over directories/files

--directories--
find csig/* -maxdepth 0 -type d  | xargs -n 1 basename
for dirName in $(find ~/csig/* -maxdepth 0 -type d | xargs -n 1 basename); do echo ${dirName}; done

#To remove path & get just dir name
baseDirName=$(basename "$dirName")

--Files--
find csig/* -maxdepth 0 -type f | xargs -n 1 basename
find csig/* -maxdepth 0 -type f  -name "*.csv" 
#Using find
for fileName in $(find ~/csig/* -maxdepth 0 -type f | xargs -n 1 basename); do
 echo "Full Name: ${fileName}  -> $(basename "${fileName}")"
done

#Using ls (use ls only if known file ext or use -f to get file only)
for fileName in $(ls ~/csig/*.json); do
 [ -f "$fileName" ] || continue
 echo "Full Name: ${fileName}  -> $(basename "${fileName}")"
done


