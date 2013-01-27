# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
Processes = require 'Processes'; fs = require 'file-system'
watch_directories = require 'boot/debug-watch-directories'
rmdirs = require('dirs').rmdirs

args = [
  '--debug'
  fs.node "scripts/app-init.js"
  fs.node "scripts/server.coffee"
  "config=debug"]
args = args.concat process.argv.slice(3)

node = Processes('node')

# if server code changes, restart server and node-inspector
watch = require('node-watch')
for dir in watch_directories.server
  try
    watch dir, -> node.kill()
  catch exception;

# kick everything off by starting the server for the first time
node.restart args...
node.on 'exit', ->
  # flush the generated files. This is because generators
  # that can include sub-files (i.e. less) will not pick
  # up a file change. Note that you will also have to place
  # directories with these files in your local
  # debug-watch-directories.coffee
  rmdirs fs.base('gen')
  console.log 'restarting server...'

# then waiting a bit before starting the debugger proxy
require('demand') 'node-inspector', (error) ->
  throw error if error
  node_inspector = Processes('node-inspector')
  setTimeout (-> node_inspector.spawn ->), 2000

#Sublime Text 2 manages to save files without triggering the watcher.
# Go to menu Tools // Build System // New Build System...
# Set file content to:
# {
#  "cmd": ["curl 'http://localhost:9009/server/http/terminate.coffee'"],
#  "shell": true
# }
# save it and set it from the same menu
# Now press <Command>B to save all files and restart your node server
