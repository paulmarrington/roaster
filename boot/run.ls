# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'file-system'

usage = ->
  cmds = file-system.readdirSync file-system.node 'scripts'
  cmds = [name.split('.')[0] for name in cmds when name[0] isnt '.'].sort()
  console.log "usage: #{file-system.node!}/go [#{cmds}] [args]"
  process.exit(1)

usage! if process.argv.length < 4
[cmd,...args] = process.argv.slice(3)

require(file-system.node 'scripts' cmd)(...args)
