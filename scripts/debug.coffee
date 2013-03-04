# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
fs = require 'file-system'; rmdirs = require('dirs').rmdirs
processes = require 'processes'

module.exports = (args...) ->
  debugging = 'server'
  if args[0][0] is '-'
    [debugging, args...] = args

  if debugging is 'server'
    clean_gen = ->
      rmdirs fs.base('gen')
      rmdirs fs.node('gen')
    clean_gen()
    args = [args..., "config=debug"]
    node = require('scripts/server')(args, true)

    node.on 'exit', ->
      # flush the generated files. This is because generators
      # that can include sub-files (i.e. less) will not pick
      # up a file change. Note that you will also have to place
      # directories with these files in your local
      # debug-watch-directories.coffee
      clean_gen()
      console.log 'restarting server...'
  else # not server
    node = processes('node')
    load = fs.node 'boot/load.js'
    console.log "Debugging - Continue needed before code executes"
    node.spawn '--debug-brk', load, 'boot/run', debugging[1..], args..., (code) ->
      console.log "Debug monitor closing"
      process.exit(code)

  # then waiting a bit before starting the debugger proxy
  # Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
  demand = require 'demand'; processes = require 'processes'

  node_inspector = ->
    demand 'node-inspector', (error) ->
      throw error if error

      cmd = fs.node "ext/node_modules/node-inspector/bin/inspector.js"
      args = [
        "--web-host=127.0.0.1",
        "--web-port=9011",
        "--prefix", fs.node 'ext']

      processes(cmd).node args..., -> console.log "Node Inspector closed"
  setTimeout node_inspector, 2000

#Sublime Text 2 manages to save files without triggering the watcher.
# Go to menu Tools // Build System // New Build System...
# Set file content to:
# {
#  "cmd": ["curl 'http://localhost:9009/server/http/terminate.coffee'"],
#  "shell": true
# }
# save it and set it from the same menu
# Now press <Command>B to save all files and restart your node server
