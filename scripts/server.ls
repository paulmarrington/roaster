# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'Processes'; require! 'file-system'

module.exports = (...args) ->
  node = Processes('node')
  load = file-system.node 'boot/load.js'
  server = file-system.node 'server/boot/server'
  node.restart load, server, ...args
  return node
