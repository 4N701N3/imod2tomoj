# imod2tomoj
## IMOD to TomoJ landmarks convertor

This script is used to convert IMOD landmarks into TomoJ landmarks.
Converts .fid + .prexg (IMOD) to .txt (TOMOJ).
This conversion is needed because the coordinates of TomoJ landmarks "
are based on the initial images rather than prealigned images like"
with IMOD."

### Prerequisite:

IMOD needs to be installed on your machine (see: https://bio3d.colorado.edu/imod/download.html).

### Usage: 
```
$ chmod +x imod2tomoj.sh
$ ./imod2tomoj.sh -b files_basename
```
