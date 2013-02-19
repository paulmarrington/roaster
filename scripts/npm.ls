# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! processes; require! 'file-system'

module.exports = (...args) ->
  cmd = file-system.node "ext/node/bin/npm"
  args = ["--prefix", file-system.node("ext"), ...args]

  processes('node').spawn cmd, ...args, ->
