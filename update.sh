#!/bin/bash
# Copyright (C) 2012,14 paul@marrington.net, see GPL license

cd "$(cd $(dirname "$0"); pwd)"

if [ -d ".git" ]; then
  git pull
  ./go.sh update
  exit
fi
install/install-roaster.sh