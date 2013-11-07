# Copyright (C) 2013 paul@marrington.net, see GPL for license

module.exports =
  # call before anything is done to initialise the server
  pre: (environment) ->
  # call after server has started listening for connections
  post: (environment) ->

# # set new patterns to decide on script domain (client, server, system)
# setDomain = require('set-domain')
# setDomain.patterns.push [/\Wclient\W/, domains.client]
# setDomain.activate()
