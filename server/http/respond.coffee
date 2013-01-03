# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
send = require 'send'

# http://localhost:9009/server/save?file=/My_Project/usdlc/Development/index.html
# contents of the file is in the body of the request as a binary stream
module.exports = (exchange, filename = exchange.request.filename) ->
  # by default we send it as static content where the browser caches it forever
  send(exchange.request, filename).maxage(Infinity).pipe(exchange.response)

module.exports.set_mime_type = (filename, response) ->
  return if response.getHeader 'Content-Type'
  type = send.mime.lookup filename
  if (charset = send.mime.charsets.lookup type)
    type += "; charset=#{charset}"
  response.setHeader 'Content-Type', type
