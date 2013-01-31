# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'file-system'
# Using faye for pubsub.

# client:
# step(
#   () ->
#     @depends '/client/faye.coffee'
#   (error, faye) ->
#     faye.subscribe '/channel', (message) ->
#       console.log message.text
#     ...
#     faye.publish '/channel', text: 'Hello'
# )

# Same server:
# environment.faye.subscribe '/channel', (message) ->
#   console.log message.text
# ...
# environment.faye.publish '/channel', text: 'Hello' # or
# require('faye).local_client.publish '/channel', text: 'Hello'

# Different server:
# faye = require('faye')('http://localhost:9009/faye')
# faye.subscribe '/channel', (message) ->
#   console.log message.text
#   ...
# faye.publish '/channel', text: 'Hello'
module.exports = (environment) ->
  faye = require file-system.node 'ext/node_modules/faye'
  bayeux = new faye.NodeAdapter mount: '/faye' timeout: 45
  bayeux.attach environment.server
  require! faye
  return environment.faye = faye.local_client = bayeux.getClient()
