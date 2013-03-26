# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
send = require 'send'; gzip = require 'morph/gzip'; fs = require 'fs'
templates = require 'templates'; clients = {}

# http://localhost:9009/server/save?file=/My_Project/usdlc/Development/index.html
# contents of the file is in the body of the request as a binary stream
class Respond
  constructor: (@exchange) ->
    @exchange.response.setHeader(
      'Access-Control-Allow-Origin',
      exchange.environment.cors_whitelist.join ' ')
    @exchange.response.setHeader(
      'Access-Control-Allow-Headers', 'Content-Type')
  # by default we send it as static content where the browser caches it forever
  static_file: ->
    @exchange.domain = 'client'
    @exchange.reply = (next) => @send_static(next)
  send_static: (next) ->
    fs.stat name = @exchange.request.filename, (err, stats) =>
      name += '/' if stats?.isDirectory() and name.slice(-1) != '/'
      # gzip name, (error, zipped-name) =>
      #   @exchange.response.setHeader 'Content-Encoding', 'gzip'
      #   @set_mime_type name
      send(@exchange.request, name).
      maxage(@maximum_browser_cache_age).pipe(@exchange.response)
      next() if next

  # Default is for browser to cache static files for a day. This is unsuitable
  # in development so the server will reset to 1 second if in debug mode.
  # It is here so anyone else can change it if needed.
  maximum_browser_cache_age: 86400 #Infinity
  # respond to client with code to run in a sandbox
  client: (code) ->
    client = @exchange.request.filename
    return @script(clients[client]) if clients[client]
    url = @exchange.request.url.path
    options =
      template_name: 'templates/client.js'
      script: "(#{code.toString()})()\n"
      url: @exchange.request.url.path
    templates.process_text options, (js) =>
      @script clients[client] = js
  # respond to client with code
  js: (code) ->
    @script "#{code.toString()}()"
  # string representation of a scipt
  script: (text) ->
    @exchange.reply = (next) -> next()
    @exchange.respond.set_mime_type 'js'
    @exchange.response.setHeader 'Cache-Control',
      'public, max-age=#{maximum_browser_cache_age}'
    @exchange.response.setHeader 'content-length', text.length
    @exchange.response.end text
  # respond to client with some JSON for browser script consumption
  json: (data, replacer = null, space = '  ') ->
    @exchange.respond.set_mime_type 'json'
    json = JSON.stringify data, replacer, space
    @text json
  # string representation of data that changes on every request
  text: (text) ->
    @exchange.response.setHeader 'Cache-Control', 'public, no-cache'
    @exchange.response.setHeader 'content-length', text.length
    @exchange.response.end text
  # morph (compile) one language to another (usually javascriot or css)
  morph: (morph, next) ->
    morph @exchange.request.filename, (error, filename, changed) =>
      @exchange.request.filename = filename
      if changed and @exchange.template
        @exchange.template filename, -> next error, @exchange
      else
        next error, @exchange
  # helper to set the mime-type in a response object based on file name
  set_mime_type: (name) ->
    return if @exchange.response.getHeader 'Content-Type'
    slash = name.indexOf('/') + 1
    name = name.slice(slash) if slash
    name = ".#{name}" if name.indexOf('.') is -1
    type = send.mime.lookup name
    if (charset = send.mime.charsets.lookup type)
      type += "; charset=#{charset}"
    @exchange.response.setHeader 'Content-Type', type

module.exports = (exchange) -> new Respond(exchange)
