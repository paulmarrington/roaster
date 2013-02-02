# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'file-system'; require! dirs.rmdirs

module.exports = (...args) ->
  rmdirs file-system.base('gen')
  args = [...args, "config=debug"]
  node = require(file-system.node 'scripts/server')(args, true)

  node.on 'exit', ->
    # flush the generated files. This is because generators
    # that can include sub-files (i.e. less) will not pick
    # up a file change. Note that you will also have to place
    # directories with these files in your local
    # debug-watch-directories.coffee
    rmdirs file-system.base('gen')
    console.log 'restarting server...'

# then waiting a bit before starting the debugger proxy
# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! demand; require! Processes; require! 'file-system'

node-inspector = (...args) ->
  demand 'node-inspector', (error) ->
    throw error if error

    cmd = file-system.node "ext/node_modules/node-inspector/bin/inspector.js"
    args =
      "--web-host=127.0.0.1"
      "--web-port=9011"
      "--prefix" file-system.node 'ext'

    Processes(cmd).node ...args, ->
      console.log "Node Inspector closed"
# setTimeout require('scripts/node-inspector'), 2000
setTimeout node-inspector, 2000

#Sublime Text 2 manages to save files without triggering the watcher.
# Go to menu Tools // Build System // New Build System...
# Set file content to:
# {
#  "cmd": ["curl 'http://localhost:9009/server/http/terminate.coffee'"],
#  "shell": true
# }
# save it and set it from the same menu
# Now press <Command>B to save all files and restart your node server
