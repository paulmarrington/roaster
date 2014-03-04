#!/bin/bash
# Copyright (C) 2012,13 paul@marrington.net, see GPL license

parent=${1:-.}
project=${2:-roaster}
from="https://github.com/uSDLC/$project/archive/master.zip"
from=${3:-$from}
archive=${4:-master.zip}
unzipped=${5:-$project-master}
base=$parent/$project
ext=$base/ext

echo "Installing '$project' to '$base'"
echo

mkdir -p $ext 2>/dev/null

echo "Download $from"
if hash curl 2>/dev/null; then
  curl -sOL $from $from
else
  wget -N -O master.zip $from
fi
echo "Unpack $unzipped"
rm -rf $unzipped
unzip -qu $archive
rm $archive
echo "Update $base"
rsync -qrulpt $unzipped/ $base
rm -rf $unzipped

cd $base
echo "Configure $base"
./go.sh update