# Copyright (C) 2013 paul@marrington.net, see /GPL for license
packages = require 'packages'

module.exports = (exchange) ->
  packages exchange.request.url.query, (results) ->
    exchange.respond.json results
