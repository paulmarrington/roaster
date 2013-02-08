# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'file-system'

usage = ->
  node = file-system.node 'scripts'
  base = file-system.base 'scripts'
  cmds = file-system.readdirSync node
  cmds ++= file-system.readdirSync base if node isnt base
  cmds = [name.split('.')[0] for name in cmds when name[0] isnt '.'].sort()
  console.log "usage: #{file-system.node!}/go [#{cmds}] [args]"
  process.exit(1)

usage! if process.argv.length < 4
[cmd,...args] = process.argv.slice(3)

require("scripts/#cmd")(...args)
