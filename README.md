# imod2tomoj
## IMOD to TomoJ landmarks convertor

This script is used to convert IMOD landmarks into TomoJ landmarks.
Converts *.fid* + *.prexg* ([IMOD](https://bio3d.colorado.edu/imod/)) to *.txt* ([TOMOJ](http://www.cmib.fr/fr/telechargements/softwares/TomoJ.html)).
This conversion is needed because the coordinates of TomoJ landmarks are based on the original (untransformed) images rather than prealigned images as with IMOD.

### Prerequisite:

IMOD needs to be installed on your machine (see: https://bio3d.colorado.edu/imod/download.html).

### Usage: 
```
$ chmod +x imod2tomoj.sh
$ ./imod2tomoj.sh -b files_basename
```
