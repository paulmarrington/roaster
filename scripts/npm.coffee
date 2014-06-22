# Copyright (C) 2012,14 paul@marrington.net, see /GPL license
processes = require 'processes'; dirs = require 'dirs'

module.exports = (args...) ->
  cmd = dirs.node "ext/node/lib/node_modules/npm/lib/npm.js"
  args = ["--prefix", dirs.node("ext"), args...]

  processes('node').spawn cmd, args..., ->