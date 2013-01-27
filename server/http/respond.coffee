# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
send = require 'send'; path = require 'path'; gzip = require 'morph/gzip'
step = require 'step'

# Default is for browser to cache static files forever. This is unsuitable in development
# so the server will reset to 1 second if in debug mode. It is here so anyone else
# can change it if needed.
maximum_browser_cache_age = Infinity

# http://localhost:9009/server/save?file=/My_Project/usdlc/Development/index.html
# contents of the file is in the body of the request as a binary stream
module.exports = respond =
  # by default we send it as static content where the browser caches it forever
  static: (exchange) ->
    send(exchange.request, exchange.request.filename).
      maxage(maximum_browser_cache_age).pipe(exchange.response)
  # morph (compile) one language to another (usually javascriot or css)
  morphed: (exchange, morph, next) ->
    morph exchange.request.filename, (error, filename) ->
      exchange.request.filename = filename
      next error, exchange
  # after morphing create a gzip version for sending ot a browser
  morph_gzip_reply: (exchange, morph) ->
    exchange.domain = 'client'
    step(
      -> respond.morphed exchange, morph, this
      -> gzip exchange.request.filename, this
      -> respond.static exchange
    )
  # helper to set the mime-type in a response object based on file name
  set_mime_type: (name, response) ->
    return if response.getHeader 'Content-Type'
    slash = name.indexOf('/') + 1
    name = name[slash..] if slash
    name = ".#{name}" if name.indexOf('.') is -1
    type = send.mime.lookup name
    if (charset = send.mime.charsets.lookup type)
      type += "; charset=#{charset}"
    response.setHeader 'Content-Type', type
