# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
processes = require 'processes'; dirs = require 'dirs'

module.exports = (args...) ->
  cmd = dirs.node "ext/node/bin/npm"
  args = ["--prefix", dirs.node("ext"), args...]

  processes('node').spawn cmd, args..., ->
