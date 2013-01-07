# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
send = require 'send'; path = require 'path'; gzip = require 'morph/gzip'
step = require 'step'; respond = require 'http/respond'

# http://localhost:9009/server/save?file=/My_Project/usdlc/Development/index.html
# contents of the file is in the body of the request as a binary stream
module.exports = respond = 
  static: (exchange) ->
    # by default we send it as static content where the browser caches it forever
    send(exchange.request, exchange.request.filename).maxage(Infinity).pipe(exchange.response)

  morphed: (exchange, morph, next) ->
    morph exchange.request.filename, (error, filename) ->
      exchange.request.filename = filename
      next error, exchange

  morph_gzip_reply: (exchange, morph) ->
    step(
      -> respond.morphed exchange, morph, this
      (error) ->
        throw error if error
        gzip exchange.request.filename, this
      (error) ->
        throw error if error
        exchange.reply exchange
    )

  set_mime_type: (name, response) ->
    return if response.getHeader 'Content-Type'
    slash = name.indexOf '/' + 1
    name = name[slash..] if slash
    name = ".#{name}" if name.indexOf('.') is -1
    type = send.mime.lookup name
    if (charset = send.mime.charsets.lookup type)
      type += "; charset=#{charset}"
    response.setHeader 'Content-Type', type
