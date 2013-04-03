# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
processes = require 'processes'; dirs = require 'dirs'
npm = require 'scripts/npm'

module.exports = (args...) ->
  update_node = dirs.node "release/update-node-on-unix"
  processes(update_node).spawn ->
    npm 'update'
