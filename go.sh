#!/bin/bash
#Copyright (C) 2012,13 paul@marrington.net, /GPL for license
bp="$(pwd)"
np="$(cd $(dirname "$0"); pwd)"

cd "$np"
"install/update-node.sh"
cd "$bp"

"$np/ext/node/bin/node" $DEBUG_NODE "$np/boot/load.js" "boot/run" $@