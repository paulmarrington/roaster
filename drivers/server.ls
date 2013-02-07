# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! system.throw-error

# script is to be run on the server, load using require
module.exports = (exchange) ->
  exchange.reply = -> require(exchange.request.filename)(exchange)
