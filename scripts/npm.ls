# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! Processes; require! 'file-system'

module.exports = (...args) ->
  cmd = file-system.node "ext/node/bin/npm"
  args = ["--prefix", file-system.node("ext"), ...args]

  Processes('node').spawn cmd, ...args, ->
