# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
template = require('server/http/ext/coffee').template; respond = require 'http/respond'

# script is to be run on the client - send back compiled version
module.exports = (exchange) ->
  template exchange, (filename) -> respond(exchange, filename)
