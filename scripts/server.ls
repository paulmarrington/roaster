# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'processes'; require! 'file-system'

module.exports = (...args, debug) ->
  node = processes('node')
  load = file-system.node 'boot/load.js'
  server = file-system.node 'server/boot/server'
  if debug
    node.restart '--debug', load, server, ...args
  else
    node.restart load, server, ...args
  return node
