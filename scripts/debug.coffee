# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
fs = require 'file-system'; rmdirs = require('dirs').rmdirs
processes = require 'processes'; demand = require 'demand'
path = require 'path'

module.exports = (args...) ->
  debugging = 'server'
  debugging = args.shift()[1..] if args[0]?[0] is '-'
  debugging = debugging[1..] if no_node_inspector = (debugging[0] is '-')

  if debugging is 'server'
    clean_gen = -> #rmdirs fs.node('gen')
    clean_gen()
    args = [args..., "config=debug"]
    node = require('scripts/server').debug(args...)

    node.on 'exit', ->
      # flush the generated files. This is because generators
      # that can include sub-files (i.e. less) will not pick
      # up a file change. Note that you will also have to place
      # directories with these files in your local
      # debug-watch-directories.coffee
      clean_gen()
      console.log 'restarting server...'

    # monitor files and reboot server/browser on change

  else # not server
    node = processes('node')
    load = fs.node 'boot/load.js'
    console.log "Debugging - Continue needed before code executes"
    node.spawn '--debug-brk', load, 'boot/run', debugging, args..., (code) ->
      console.log "Debug monitor closing"
      process.exit(code)

  # then waiting a bit before starting the debugger proxy
  node_inspector = ->
    demand 'node-inspector', ->
      cmd = fs.node "ext/node_modules/node-inspector/bin/inspector.js"
      args = [
        "--web-host=127.0.0.1",
        "--web-port=9011",
        "--prefix", fs.node 'ext']

      processes(cmd).node args..., -> console.log "Node Inspector closed"
  setTimeout node_inspector, 2000 if not no_node_inspector

#Sublime Text 2 manages to save files without triggering the watcher.
# Go to menu Tools // Build System // New Build System...
# Set file content to:
# {
#  "cmd": ["curl 'http://localhost:9009/server/http/terminate.coffee'"],
#  "shell": true
# }
# save it and set it from the same menu
# Now press <Command>B to save all files and restart your node server
