# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
spawn = require('child_process').spawn; fs = require 'file-system'
spawn_options = {cwd:process.cwd(), env:process.env, stdio:'inherit'}

usdlc = node_inspector = null
args = [
  fs.node "scripts/coffee.js"
  fs.node "scripts/server.coffee"
  "debug=true"]
args = args.concat process.argv[3..-1]

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
for base in [fs.base '', fs.node '']
  for services in ['scripts', 'server', 'common']
    try
      watch "#{base}#{services}", restart
    catch exception;

# kick everything off by starting the server for the first time
restart()
