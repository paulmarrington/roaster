#!/bin/bash
#Copyright (C) 2012,13 paul@marrington.net, /GPL for license
echo
export uSDLC_base_path=$(pwd)
export uSDLC_node_path=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
# node require statements will look here
export NODE_PATH=.:$uSDLC_base_path/server:$uSDLC_base_path/scripts:$uSDLC_node_path:$uSDLC_node_path/server:$uSDLC_node_path/node_modules:$uSDLC_node_path/ext/node_modules:$uSDLC_node_path/ext/node/lib/node_modules:$uSDLC_node_path/scripts:$NODE_PATH
# add scripts and node itself to the path for convenience
export PATH=$uSDLC_node_path/ext/node/bin:$PATH

"$uSDLC_node_path/release/update-node-on-unix.sh"

case $1 in
  node)
    shift
    node $DEBUG_NODE $@
    ;;
  *)
    node $DEBUG_NODE "$uSDLC_node_path/boot/load.js" "boot/run" $@
    ;;
esac
