# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
processes = require 'processes'; fs = require 'file-system'

module.exports = (args..., debug) ->
  node = processes('node')
  load = fs.node 'boot/load.js'
  server = fs.node 'server/boot/server'
  if debug
    node.restart '--debug', load, server, args...
  else
    node.restart load, server, args...
  return node
