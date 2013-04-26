# Copyright (C) 2012 paul@marrington.net, see GPL for license

module.exports = (args...) ->
  if process.env.DEBUG_NODE
    require 'server/boot/server'
  else
    processes = require 'processes'; dirs = require 'dirs'
    load = dirs.node 'boot/load.js'
    server = dirs.node 'server/boot/server'

    node = processes('node')
    node.respawn load, server, args...
    return node
