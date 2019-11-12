#!/bin/bash

# @author Antoine Cossa
# @date 2019/10/22

sample_name=
input_file=
output_file=
prexg_file=

# Usage/help function
usage()
{
    echo "This script is used to convert IMOD landmarks into TomoJ landmarks."
    echo "Converts .fid + .prexg (IMOD) to .txt (TOMOJ)."
    echo "This conversion is needed because the coordinates of TomoJ landmarks "
    echo "are based on the initial images rather than prealigned images like"
    echo "with IMOD."
    echo ""
    echo "Usage:"
    echo "`basename $0` -b files_basename"
    exit 0
}

# Read user args
while [ "$1" != "" ]; do
    case "$1" in
        -b | --basename )       shift
                                sample_name="$1"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ $sample_name != "" ]; then
    input_file="${sample_name}.fid"
    output_file="${sample_name}_t.txt"
    prexg_file="${sample_name}.prexg"
else
    echo "Incorrect files_basename!"
    echo ""
    echo "Usage:"
    echo "`basename $0` -b files_basename"
    exit 1
fi

#################### MAIN ####################

# Extract fiducial informations from IMOD .fid file
imodinfo -v -a $input_file > fiducials.txt

# Parse an IMOD file to TOMOJ landmarks format
awk 'BEGIN { chainNb=-1 ;} { if($1 ~ /^contour/) { chainNb+=1 ;} else if ($1 ~ /^[0-9]+\.[0-9]+/) { if($3<0.0001) { $3=0; } printf"%d\t%d\t%7.3f\t%7.3f\t%s\n", chainNb, $3, $1, $2, "1" ;}}' fiducials.txt > landmarks.txt

# Substract IMOD transform to the points coordinates
awk -v prexgFile="${prexg_file}" 'BEGIN { i=0 ; while (1) { i++ ; if ((getline < prexgFile) != 0) { X[i]=$5; Y[i]=$6 } else { break }}} { coorx=$3 ; coory=$4 ; coorx-=X[$2] ; coory-=Y[$2] ; printf"%d\t%d\t%11.6f\t%11.6f\t1\n", $1, $2, coorx, coory }' < landmarks.txt > "${output_file}"


rm fiducials.txt
rm landmarks.txt

##############################################

echo "Finished!"
exit 0
