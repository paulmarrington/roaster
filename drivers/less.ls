# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'morph/less'

module.exports = (exchange, next) ->
  exchange.response.mimetype = 'css'  # most common is script
  exchange.respond.static()
  exchange.respond.morph less, next
