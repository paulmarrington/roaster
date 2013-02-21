# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
processes = require 'processes'; fs = require 'file-system'

module.exports = (...args) ->
  cmd = fs.node "ext/node/bin/npm"
  args = ["--prefix", fs.node("ext"), args...]

  processes('node').spawn cmd, args..., ->
