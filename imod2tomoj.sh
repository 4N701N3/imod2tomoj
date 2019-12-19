#!/bin/bash

# @author Antoine Cossa
# @date 2019/10/22

sample_name=
folder=
input_file=
output_file=
prexg_file=

# Usage/help function
usage()
{
    echo "-----------------------------imod2tomoj------------------------------"
    echo "This script is used to convert IMOD landmarks into TomoJ landmarks."
    echo "Converts .fid + .prexg (IMOD) to .txt (TOMOJ)."
    echo "This conversion is needed because the coordinates of TomoJ landmarks "
    echo "are based on the initial images rather than prealigned images like"
    echo "with IMOD."
    echo "---------------------------------------------------------------------"
    echo ""
    echo "Usage:"
    echo "`basename $0` -i input_folder -b files_basename"
    echo ""
    echo "Options:"
    echo "-i, --inputFolder     Path of the input folder."
    echo "-b, --basename        Sample basename."
    echo "-h, --help            Display this help."
    exit 0
}

# Read user args
while [ "$1" != "" ]; do
    case "$1" in
        -b | --basename )       shift
                                sample_name="$1"
                                ;;
        -i | --inputFolder )    shift
                                folder="$1"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ "$sample_name" != "" ]; then
    input_file="${sample_name}.fid"
    output_file="${sample_name}_t.txt"
    prexg_file="${sample_name}.prexg"
    if [ "$folder" == "" ]; then
        folder="./"
    elif [[ "$folder" != */ ]]
    then
        folder="${folder}/"
    fi
else
    echo "Incorrect files_basename!"
    echo ""
    echo "Usage:"
    echo "`basename $0` -b files_basename"
    exit 1
fi

#################### MAIN ####################

# Extract fiducial informations from IMOD .fid file
imodinfo -v -a $folder$input_file > fiducials.txt
if ([ "$?" -eq 127 ]) # if "command not found" try
then
    echo "Trying command imodinfo.exe"
    imodinfo.exe -v -a $folder$input_file > fiducials.txt
    if ([ "$?" -ne 127 ])
    then
        echo "imodinfo.exe: succeed"
    else
        echo "Command imodinfo not found!"
        echo "Please make sure IMOD is installed."
        echo "If IMOD is installed on Windows without Cigwin, make sure IMOD bin folder is in the PATH."
        echo "If not you can try: export PATH='/mnt/c/Program Files/IMOD/bin:$PATH'"
    fi
else
    echo "imodinfo: succeed"
fi

# Parse an IMOD file to TOMOJ landmarks format
awk 'BEGIN { chainNb=-1 ;} { if($1 ~ /^contour/) { chainNb+=1 ;} else if ($1 ~ /^[0-9]+\.[0-9]+/) { if($3<0.0001) { $3=0; } printf"%d\t%d\t%7.3f\t%7.3f\t%s\n", chainNb, $3+1, $1, $2, "1" ;}}' fiducials.txt > landmarks.txt

# Substract IMOD transform to the points coordinates
awk -v prexgFile="${folder}${prexg_file}" 'BEGIN { i=0 ; while (1) { i++ ; if ((getline < prexgFile) != 0) { X[i]=$5; Y[i]=$6 } else { break }}} { coorx=$3 ; coory=$4 ; coorx-=X[$2] ; coory-=Y[$2] ; printf"%d\t%d\t%11.6f\t%11.6f\t1\n", $1, $2, coorx, coory }' < landmarks.txt > "${folder}${output_file}"

rm fiducials.txt
rm landmarks.txt

##############################################

echo "New landmarks file: $folder$output_file"
exit 0
