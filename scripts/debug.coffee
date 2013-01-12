# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
spawn = require('child_process').spawn; fs = require 'file-system'
watch_directories = require 'debug-watch-directories'; rmdirs = require('dirs').rmdirs

spawn_options = {cwd:process.cwd(), env:process.env, stdio:'inherit'}

usdlc = node_inspector = null
args = [
  fs.node "scripts/coffee.js"
  fs.node "scripts/server.coffee"
  "debug=true"]
args = args.concat process.argv[3..-1]

# flush the generated files. This is because generators
# that can include sub-files (i.e. less) will not pick
# up a file change. Note that you will also have to place
# directories with these files in your local
# debug-watch-directories.coffee
rmdirs fs.base('gen')

# start uSDLC if not running else kill it forcing a restart  
restart = ->
  return usdlc.kill() if usdlc
  usdlc = spawn "node", args, spawn_options
  usdlc.on 'exit', (code, signal) ->
    usdlc = null
    console.log 'restarting server...'
    restart()

# if server code changes, restart server and node-inspector
watch = require('node-watch')
for dir in watch_directories.server
  try
    watch dir, restart
  catch exception;

# kick everything off by starting the server for the first time
restart()
# then waiting a bit before starting the debugger proxy
require('demand') 'node-inspector', (error) ->
  throw error if error
  load_node_inspector = -> spawn "node-inspector", [], spawn_options
  setTimeout load_node_inspector, 2000

#Sublime Text 2 manages to save files without triggering the watcher.
# Go to menu Tools // Build System // New Build System...
# Set file content to:
# {
#  "cmd": ["touch '$file_path'"],
#  "shell": true
# }
# save it and set it from the same menu
# Now press <Command>B to save all files and restart your node server