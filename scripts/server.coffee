# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

module.exports = (args...) ->
  if process.env.DEBUG_NODE
    require 'server/boot/server'
  else
    processes = require 'processes'; fs = require 'file-system'
    load = fs.node 'boot/load.js'
    server = fs.node 'server/boot/server'

    node = processes('node')
    node.respawn load, server, args...
    return node
