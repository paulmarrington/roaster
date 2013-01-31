# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'http/respond'

module.exports = (exchange) ->
  exchange.domain = 'client'
  exchange.reply = (morph) -> respond.morph-gzip-reply exchange, morph
