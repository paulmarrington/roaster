# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
fs = require('file-system')

# node-inspector is a program, not a module. This module will throw an
# exception if node-inspector is not installed. Otherwise, nothing happens
# used in debug.coffee to load node-inspector the first time it runs
# triggering just-in-time loading
fs.existsSync fs.node 'ext/node_modules/.bin/node-inspector'