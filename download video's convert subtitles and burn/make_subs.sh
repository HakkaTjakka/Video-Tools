#!/bin/bash
#echo Converting mtl files

# converts all *.jpg and *.bmp files to *.png and patches model.mtl


# subdirectory (optional)
sub="$*"
echo VIDEO_: \"$1\"
#echo SUBS__: \"$2\"

autosub -S en -D en "$1"
