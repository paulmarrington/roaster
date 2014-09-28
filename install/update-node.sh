#!/bin/bash
# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
base=$(cd $(dirname "$0"); pwd)

nodeVersion=v0.10.32
npmVersion=1.4.9

mkdir "$base/../ext" 2>/dev/null
cd "$base/../ext"

function unpack() { # for unix-like systems
  echo "unpack $1"
  tar -xzf $1
  dirname=${1%.tar.gz}
  mv $dirname node
}

os="`uname`-`uname -m`"
case $os in
	Darwin-x86_64) fn=node-$nodeVersion-darwin-x64.tar.gz ;;
	Darwin-i386) fn=node-$nodeVersion-darwin-x86.tar.gz ;;
	Linux-x86_64) fn=node-$nodeVersion-linux-x64.tar.gz ;;
	Linux-i386) fn=node-$nodeVersion-linux-x86.tar.gz ;;
	Linux-i686) fn=node-$nodeVersion-linux-x86.tar.gz ;;
    MINGW32_NT*) fn=node.exe
     ar=node-$nodeVersion-windows-x86.exe
     function unpack() {
       echo "prepare $ar"
       mkdir node
       mkdir node/bin
       cp node.exe node/bin
       mv node.exe $ar

       wget -H http://nodejs.org/dist/npm/npm-${npmVersion}.zip
       mkdir node/lib
       unzip -q npm-${npmVersion}.zip -d node/lib
       # ln node/lib/node_modules/npm/bin/npm-cli.js node/bin/npm
     }
     ;;
	*) echo "Unknown OS version - '$os'"
	   echo "Compile from source at 'http://nodejs.org/dist/$nodeVersion/node-$nodeVersion.tar.gz'"
	   exit
esac
if [ ! -e ${ar-$fn} ]
then
    echo "download $fn from nodejs.org"
    if hash curl 2>/dev/null; then
      curl -sOL http://nodejs.org/dist/$nodeVersion/$fn
    else
      wget -N http://nodejs.org/dist/$nodeVersion/$fn
    fi
    rm -r node 2>/dev/null
    unpack $fn
    ../go.sh update
fi
echo