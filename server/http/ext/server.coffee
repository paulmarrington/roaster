# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
respond = require 'http/respond'
throwError = require('system').throwError

# script is to be run on the server, load using require
module.exports = (exchange) ->
  exchange.domain = 'server'
  exchange.reply = (morph) ->
    respond.morphed exchange, morph, throwError ->
      require(exchange.request.filename)(exchange)
