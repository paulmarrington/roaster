# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! send
clients = {}

# http://localhost:9009/server/save?file=/My_Project/usdlc/Development/index.html
# contents of the file is in the body of the request as a binary stream
class Respond
  (@exchange) ~>
  # by default we send it as static content where the browser caches it forever
  static: -> @exchange.reply = ~> @send-static()
  send-static: ->
    send(@exchange.request, @exchange.request.filename).
      maxage(@maximum-browser-cache-age).pipe(@exchange.response)

  # Default is for browser to cache static files forever. This is unsuitable in development
  # so the server will reset to 1 second if in debug mode. It is here so anyone else
  # can change it if needed.
  maximum-browser-cache-age: Infinity
  # respond to client with code to run in a sandbox
  client: (code) ->
    if not ((client = @exchange.request.filename) of clients)
      url = @exchange.request.url.path
      clients[client] = "depends.cache['#url'] = #{code.toString()}()"
    @text clients[client]
  # respond to client with code
  js: (code) ->
    @text "_tmp_=#{code.toString()}()"
  text: (text) ->
    @exchange.response.set-header 'Cache-Control', 'public, max-age=#maximum-browser-cache-age'
    @exchange.response.set-header 'content-length', text.length
    @exchange.response.end text
  # respond to client with some JSON for browser script consumption
  json: (data, replacer = null, space = '  ') ->
    @exchange.response.mimetype = 'json'
    json = JSON.stringify data, replacer, space
    @exchange.response.set-header 'content-length', json.length
    @exchange.response.end json
  # morph (compile) one language to another (usually javascriot or css)
  morph: (morph, next) ->
    morph @exchange.request.filename, (error, filename) ~>
      @exchange.request.filename = filename
      next error, @exchange
  # helper to set the mime-type in a response object based on file name
  set-mime-type: (name) ->
    return if @exchange.response.get-header 'Content-Type'
    slash = name.indexOf('/') + 1
    name .= slice(slash) if slash
    name = ".#{name}" if name.indexOf('.') is -1
    type = send.mime.lookup name
    if (charset = send.mime.charsets.lookup type)
      type += "; charset=#{charset}"
    @exchange.response.set-header 'Content-Type', type

module.exports = Respond
