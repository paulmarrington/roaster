# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# This file is loaded by the debug script to note which directories to watch for
# changes. For server directories the server restarts. For client directories
# it instructs the client to refresh.

# Applications will want to add directories to each group. To do so it puts a file
# called debug-watch-directories.coffee in it's server directory. It can use the
# following template:

# fs = require 'file-system'
# module.exports = require fs.node 'boot/debug-watch-directories'
# module.exports.server.push [
#   fs.base 'my-server-dir'
# ]
# module.exports.client.push [
#   fs.base 'my-client-dir'
# ]
fs = require 'file-system'; path = require 'path'

module.exports =
  # Debug mode monitors these directories for server-side files
  # When they change the server is rebooted
  server: [
    fs.node 'scripts'
    fs.node 'server'
    fs.node 'common'
    fs.base 'server'
    fs.base 'common'
    fs.base 'scratch'
  ]

  # Debug mode monitors these directories for client-side files
  # When they change the client will refresh
  client: [
    fs.node 'client'
    fs.base 'client'
    fs.base 'scratch'
  ]
