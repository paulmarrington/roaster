# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

module.exports = (exchange) ->
  exchange.domain = 'client'
  exchange.reply = (morph) -> exchange.respond.morph-gzip-reply morph
