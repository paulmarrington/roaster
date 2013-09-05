# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
processes = require 'processes'; dirs = require 'dirs'

module.exports = (args...) ->
  cmd = dirs.node "ext/node/bin/npm"
  args = ["--prefix", dirs.node("ext"), args...]

  processes('node').spawn cmd, args..., ->
