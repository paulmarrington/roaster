# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
fs = require 'file-system';

module.exports = (exchange) ->
  exchange.respond.set_mime_type 'ico'  # most common is script
  if exchange.request.url.pathname is '/favicon.ico'
    exchange.request.filename = fs.base "client/favicon.ico"
  exchange.respond.static()
