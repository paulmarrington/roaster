# Copyright (C) 2013 paul@marrington.net, see GPL for license
stylus = require 'morph/stylus'

module.exports = (exchange, next) ->
  exchange.respond.set_mime_type 'css'  # most common is script
  exchange.respond.static_file()
  exchange.respond.morph stylus, next
