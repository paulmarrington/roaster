# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'http/respond'; require! 'script-runner'

# Javascript targets can run in the browser, server or external node instance.
# Normally this is handled by having the domain in the file-name
# (i.e. filename.client.coffee). If that fails we can look for specific
# patterns in the file paths. If that also fails we will assume it is a
# server file
patterns =
  [/\Wclient\W/, 'client']
  [/\Wserver\W/, 'server']
  [/\W(usdlc|node|system)\W/, 'node']

search-using-path = (exchange) ->
    for pattern in patterns
      if pattern[0].test exchange.request.filename
        return require("http/ext/#{pattern[1]}")(exchange)
    return require('http/ext/server')(exchange)

setter = set-default-to-server = (exchange) ->
  require('http/ext/server')(exchange)

module.exports =
  # Set the domain (client, server or node) for js to run in
  set: !(exchange) -> setter(exchange) if not exchange.domain
  # set new patterns to decide on script domain (client, server, system)
  patterns: patterns
  # Normally we will leave it at that and just user a server domain
  # for anything not in the extension string. To check other patters
  # in the file path, set activate to true. See project-init.coffee
  activate: -> setter = search-using-path
