#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Error: Illegal number of parameters"
    echo "Usage: $0/pe_versions.sh <2016|2017|2018|2019>"
    exit
fi

year=$1

if [ $1 -ne 2016 ] && [ $1 -ne 2017 ] && [ $1 -ne 2018 ] && [ $1 -ne 2019 ]; then
   echo "Error: Valid PE version years are 2016-2019"
   echo "Usage: pe_versions.sh <2016|2017|2018|2019>"
   exit 
fi

# generate a temp file with a random part in the name
version_file="/tmp/pe-versions-`date +'%s%m%y'`.txt"

# All the PE versions are maintained in an online file. Download it to a temp file
curl -s http://versions.puppet.com.s3-website-us-west-2.amazonaws.com/ > $version_file

echo -n "Puppet Enterprise versions released in Year $year :"
# grep all the versions in that year.
values=$(grep $year $version_file)
if [ -z "$values" ]; then
    echo " Zero matches"
else
    echo ""
    echo $values
fi
# delete the temp file
unlink $version_file
