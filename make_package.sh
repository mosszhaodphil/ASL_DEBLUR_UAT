#!/bin/sh

# Make an asl_deblur package

if [ -z $1 ]; then
    echo "ERROR: specify MATLAB directory (to find deploytool)"
    exit 1
fi

if [ $1 = "osx" ]; then
    # reserved for local testingma
    matlabroot=/Applications/MATLAB_R2012b.app
else
    matlabroot=$1
fi

# first we complie the matlab part
$matlabroot/bin/deploytool -build asl_deblur_core.prj

# now we build a package
rm -rf asl_deblur_package
mkdir asl_deblur_package

#first deal with the main shell script
cp asl_deblur asl_deblur_package/ 
#this gets the copyright consistent with FSL
${FSLCONFDIR}/common/insertcopyright asl_deblur_package/asl_deblur

# now deal with the output of matlab deploytool
cp asl_deblur_core/distrib/run_asl_deblur_core.sh asl_deblur_package/run_asl_deblur_core
if [ -d asl_deblur_core/distrib/asl_deblur_core.app ]; then 
    cp -rf asl_deblur_core/distrib/asl_deblur_core.app asl_deblur_package/ ;
fi;
if [ -f asl_deblur_core/distrib/asl_deblur_core ]; then
    cp asl_deblur_core/distrib/asl_deblur_core asl_deblur_package/ ;
fi;

rm asl_deblur_package.tar
tar -cf asl_deblur_package.tar asl_deblur_package