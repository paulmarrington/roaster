# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
processes = require 'processes'; fs = require 'file-system'
npm = require 'scripts/npm'

module.exports = (args...) ->
  update_node = fs.node "release/update-node-on-unix"
  processes(update_node).spawn ->
    npm 'update'
