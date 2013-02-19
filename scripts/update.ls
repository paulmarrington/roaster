# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! processes; require! 'file-system'; require! 'scripts/npm'

module.exports = (...args) ->
  update-node = file-system.node "bin/update-node-on-unix"
  processes(update-node).spawn ->
    npm 'update'
