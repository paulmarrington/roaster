# Copyright (C) 2012 paul@marrington.net, see GPL for license
module.exports = (args...) ->
  if process.env.DEBUG_NODE or args[0] is 'mode=gwt'
    require 'server/boot/server'
  else
    processes = require 'processes'; dirs = require 'dirs'
    load = dirs.node 'boot/load.js'
    server = dirs.node 'server/boot/server'

    node = processes('node')
    insp = 'ext/node_modules/node-inspector/bin/inspector.js'
    if args[0] is 'config=inspect'
      debug = ->
        try
          inspector = processes('node').
            spawn dirs.node(insp), '', ->
        catch e
        node.respawn '--debug', load, server, args...
      
      try # Don't require if it has been loaded
        require.resolve 'node-inspector'
      catch e # we need to load using npm
        return require('npm').load 'node-inspector', debug
      debug()
    else
      node.respawn load, server, args...
    return node
