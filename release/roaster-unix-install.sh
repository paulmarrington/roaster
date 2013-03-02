#!/bin/bash
# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

####################################################
# Install where commanded or to the default location
####################################################
base=${1:-~/dev/roaster}
echo "Installing roaster to '$base' (move it afterwards if you like)"
echo "The best place for it is the directory containing all your development projects"
###############################
# Set up our target directories
###############################
ext=$base/ext
mkdir -p $ext 2>/dev/null

##########################################################################
# First is uSDLC2 as it includes scripts needed to finish the installation
##########################################################################
curl -sOL https://github.com/uSDLC/roaster/archive/master.zip
rm -rf roaster-master
unzip -q master.zip
rm master.zip
rsync -qrulpt roaster-master/ $base
rm -rf roaster-master

################################################################
# Now we can run packages stuff to install Node and node-modules
################################################################
cd $base
case $2 in
  no-go) echo "To complete installation run '$base/go'"
         ;;
  *) ./go.sh
     ;;
esac
