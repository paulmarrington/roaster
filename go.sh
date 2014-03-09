#!/bin/bash
#Copyright (C) 2012,13 paul@marrington.net, /GPL for license
bp="$(pwd)"
np="$(cd $(dirname "$0"); pwd)"
#export uSDLC_base_path="$bp"
#export uSDLC_node_path="$np"
# node require statements will look here
#bps="$bp/server:$bp/common:$bp/scripts"
#nps="$np:$np/server:$np/common:$np/scripts"
#nm="$np/ext/node_modules:$np/ext/node/lib/node_modules"
#export NODE_PATH=".:$bps:$nps:$nm:$NODE_PATH"

# add scripts and node itself to the path for convenience
#nbp="$np/ext/node/bin"
#export PATH="$nbp:$PATH"

cd "$np"
"release/update-node.sh"
cd "$bp"

#case $1 in
#  node) shift
#    node $DEBUG_NODE $@ ;;
#  *)
$np/ext/node/bin/node $DEBUG_NODE "boot/load.js" "boot/run" $@
#;;
#esac
