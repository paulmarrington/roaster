# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
fs = require 'fs'; dirs = require 'dirs'

usage = ->
  node = dirs.node 'scripts'
  base = dirs.base 'scripts'
  cmds = fs.readdirSync node
  cmds = cmds.concat fs.readdirSync base if node isnt base
  cmds = [name.split('.')[0] for name in cmds when name[0] isnt '.'].sort()
  console.log "usage: #{dirs.node()}/go [#{cmds}] [args]"
  process.exit(1)

usage() if process.argv.length < 4
[cmd,args...] = process.argv.slice(3)

require("scripts/#{cmd}")(args...)
