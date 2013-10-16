# Copyright (C) 2013 paul@marrington.net, see /GPL for license
dirs = require 'dirs'; queue = require 'queue'
# Using faye for pubsub.

# client:
#   queue ->
#     @depends '/client/faye.coffee'
#     @faye.subscribe '/channel', (message) ->
#       console.log message.text
#     ...
#     @faye.publish '/channel', text: 'Hello'
# )

# Same server:
# environment.faye.subscribe '/channel', (message) ->
#   console.log message.text
# ...
# environment.faye.publish '/channel', text: 'Hello' # or
# require('faye').local_client.publish '/channel', text: '?'

# Different server:
# faye = require('faye')('http://localhost:9009/faye')
# faye.subscribe '/channel', (message) ->
#   console.log message.text
#   ...
# faye.publish '/channel', text: 'Hello'
module.exports = (environment) -> queue ->
  @requires dirs.node('ext/node_modules/faye'), ->
    bayeux = new @faye.NodeAdapter mount: '/faye', timeout: 45
    bayeux.attach environment.http_server
    environment.faye = @faye.local_client = bayeux.getClient()
