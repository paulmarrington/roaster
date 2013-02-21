# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
less = require 'morph/less'

module.exports = (exchange, next) ->
  exchange.respond.set_mime_type 'css'  # most common is script
  exchange.respond.static()
  exchange.respond.morph less, next
