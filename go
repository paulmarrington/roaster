#!/bin/bash
echo "Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license"
echo
# The go script is in the root directory of uSDLC2 Node
export uSDLC_node_path=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
export uSDLC_base_path=$uSDLC_node_path
# node require statements will look here
export NODE_PATH=./server:./common:$uSDLC_node_path/server:$uSDLC_node_path/common:$uSDLC_node_path/ext/node_modules:$uSDLC_node_path/ext/node/lib/node_modules:.:$NODE_PATH
# add scripts and node itself to the path for convenience
export PATH=$uSDLC_node_path/bin:$uSDLC_node_path/ext/node/bin:$PATH

# Is this a first-time run - as will happen after uns-unix-install.sh is run
if [ ! -d "$uSDLC_node_path/ext/node" ]; then
    echo "First time only install of node.js to"
    echo "    $uSDLC_node_path"
    "$uSDLC_node_path/bin/update-node-on-unix"
    npm --silent install coffee-script send cookies node-watch
fi

echo "usage: go server|debug|update|node|npm|node-inspector ..."
# run node or one of the scripts from uSDLC2/bin
$@