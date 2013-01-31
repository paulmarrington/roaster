# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# This file is loaded by the debug script to note which directories to watch for
# changes. For server directories the server restarts. For client directories
# it instructs the client to refresh.

# Applications will want to add directories to each group. To do so it puts a file
# called debug-watch-directories.coffee in it's server directory. It can use the
# following template:

# fs = require 'file-system'
# module.exports = require file-system.node 'boot/debug-watch-directories'
# module.exports.server.push [
#   file-system.base 'my-server-dir'
# ]
# module.exports.client.push [
#   file-system.base 'my-client-dir'
# ]
require! 'file-system'; require! path

module.exports =
  # Debug mode monitors these directories for server-side files
  # When they change the server is rebooted
  server:
    file-system.node 'scripts'
    file-system.node 'server'
    file-system.node 'common'
    file-system.base 'server'
    file-system.base 'common'
    file-system.base 'scratch'

  # Debug mode monitors these directories for client-side files
  # When they change the client will refresh
  client:
    file-system.node 'client'
    file-system.base 'client'
    file-system.base 'scratch'
