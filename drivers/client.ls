# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

module.exports = (exchange) ->
  exchange.reply = -> exchange.respond.client-gzip-reply!
