# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
morph = require 'morph'

module.exports = (exchange, next) ->
  if exchange.template
    exchange.respond.morph morph.copier, next
  else
    next(null, exchange.request.filename)
