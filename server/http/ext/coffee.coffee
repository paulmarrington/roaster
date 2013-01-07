# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# Coffee-script files can be sent to the browser to run, run on the server
# or spawned off to a separate process. These domains can be specified in
# more than one way:

# * The path a script is on (i.e. /client/ in the path somewhere)
# * file name extension (myfile.client.coffee)
# * explicit in a wrapping script setting exchange.domain

path = require 'path'; coffee_morph = require 'morph/coffee'
script_runner = require 'script-runner'; respond = require 'http/respond'

domains = 
  client: require 'http/ext/client.coffee'
  server: require 'http/ext/server.coffee'
  node:   require 'http/ext/node.coffee'

module.exports = (exchange) ->
  # domain can be set by wrap_client_dependency for client depends command
  if not exchange.domain
    if exchange.request.filename.indexOf('/client/') isnt -1
      exchange.domain = 'client'
    else if exchange.request.filename.indexOf('/usdlc/') isnt -1
      exchange.domain = 'node'
    else
      exchange.domain = 'server'

  domains[exchange.domain](exchange)
