# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
respond = require 'http/respond'

module.exports = (exchange) ->
  exchange.response.mimetype ?= 'js'  # most common is script
  exchange.reply = (morph) -> respond.morph_gzip_reply exchange, morph
