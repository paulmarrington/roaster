# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
morph = require 'morph/coffee'; respond = require 'http/respond'
throw_error = require('system').throw_error

# script is to be run on the server, load using require
module.exports = (exchange) ->
  respond.morphed exchange, morph, throw_error ->
    require(exchange.request.filename)(exchange)
