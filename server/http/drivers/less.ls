# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'morph/less'; require! 'http/respond'

module.exports = (exchange) ->
  exchange.domain = 'client'
  exchange.response.mimetype = 'css'  # most common is script
  exchange.morph = less
  exchange.reply = (morph) -> respond.morph-gzip-reply exchange, morph
