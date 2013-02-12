# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! send; require! 'morph/gzip'
clients = {}

# http://localhost:9009/server/save?file=/My_Project/usdlc/Development/index.html
# contents of the file is in the body of the request as a binary stream
class Respond
  (@exchange) ~>
  # by default we send it as static content where the browser caches it forever
  static: -> @exchange.reply = ~> @send-static()
  send-static: ->
    name = @exchange.request.filename
    gzip name, (error, zipped-name) ~>
      @exchange.response.set-header 'Content-Encoding', 'gzip'
      @set-mime-type name
      send(@exchange.request, zipped-name).
        maxage(@maximum-browser-cache-age).pipe(@exchange.response)

  # Default is for browser to cache static files forever. This is unsuitable in development
  # so the server will reset to 1 second if in debug mode. It is here so anyone else
  # can change it if needed.
  maximum-browser-cache-age: 86_400seconds #Infinity
  # respond to client with code to run in a sandbox
  client: (...functions) ->
    if not ((client = @exchange.request.filename) of clients)
      url = @exchange.request.url.path
      functions = ["#{func.toString()}()" for func in functions]
      functions .= join(',')
      # null is actally error first paramenter in cliend depends()
      clients[client] = "roaster.cache['#url'] = [null,#functions]"
    @script clients[client]
  # respond to client with code
  js: (code) ->
    @script "_tmp_=#{code.toString()}()"
  # string representation of a scipt
  script: (text) ->
    @exchange.respond.set-mime-type 'js'
    @exchange.response.set-header 'Cache-Control', 'public, max-age=#maximum-browser-cache-age'
    @exchange.response.set-header 'content-length', text.length
    @exchange.response.end text
  # respond to client with some JSON for browser script consumption
  json: (data, replacer = null, space = '  ') ->
    @exchange.respond.set-mime-type 'json'
    json = JSON.stringify data, replacer, space
    @text json
  # string representation of data that changes on every request
  text: (text) ->
    @exchange.response.set-header 'Cache-Control', 'public, no-cache'
    @exchange.response.set-header 'content-length', text.length
    @exchange.response.end text
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
