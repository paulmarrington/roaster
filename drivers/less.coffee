# Copyright (C) 2012 paul@marrington.net, see GPL for license
less = require 'morph/less'

module.exports = (exchange, next) ->
  exchange.respond.set_mime_type 'css'  # most common is script
  exchange.respond.static_file()
  exchange.respond.morph less, next
