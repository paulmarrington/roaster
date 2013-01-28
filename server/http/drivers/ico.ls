# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'http/respond'; require! 'file-system';

module.exports = (exchange) ->
  exchange.domain = 'client'
  exchange.response.mimetype ?= 'js'  # most common is script
  if exchange.request.url.pathname is '/favicon.ico'
    exchange.request.filename = file-system.base "client/favicon.ico"
