# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! Processes; require! 'file-system'; require! 'scripts/npm'

module.exports = (...args) ->
  update-node = file-system.node "bin/update-node-on-unix"
  Processes(update-node).spawn ->
    npm 'update'
