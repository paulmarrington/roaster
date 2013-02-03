# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'http/drivers/server'

module.exports = (exchange) ->
  exchange.response.mimetype = 'json'
  # json on end extension is static file
  return exchange.respond.static! if exchange.last-driver

  server exchange # like a server
  exchange.post = ->
    if exchange.response.data
      text = JSON.stringify exchange.response.data
      exchange.response.set-header 'content-length', text.length
      exchange.response.end text

