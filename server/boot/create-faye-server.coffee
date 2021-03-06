# Copyright (C) 2013 paul@marrington.net, see /GPL for license
dirs = require 'dirs'
npm = require 'npm'

# Using faye for pubsub.

# client:
#   faye.subscribe '/channel', (message) ->
#     console.log message.text
#   ...
#   faye.publish '/channel', text: 'Hello'
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

module.exports = (environment, next) ->
  npm 'faye', (error, faye) ->
    bayeux = new faye.NodeAdapter mount: '/faye', timeout: 45
    bayeux.attach environment.http_server
    environment.faye = faye.local_client = bayeux.getClient()
    environment.faye.bayeux = bayeux
    next()
