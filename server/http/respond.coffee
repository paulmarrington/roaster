# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
send = require 'send'; gzip = require 'morph/gzip'
fs = require 'fs'; templates = require 'templates'
path = require 'path'; dirs = require 'dirs'

clients = {}

# http://localhost:9009/server/save?file=
#  /My_Project/usdlc/Development/index.html
# contents of file is in the body of request as a binary stream
class Respond
  constructor: (@exchange) ->
    @exchange.response.setHeader(
      'Access-Control-Allow-Origin',
      @exchange.environment.cors_whitelist.join ' ')
    @exchange.response.setHeader(
      'Access-Control-Allow-Headers',
      @exchange.request.headers['Access-Control-Request-Headers'] ?
      "Content-Type pragma")
    @exchange.response.setHeader(
      'Access-Control-Allow-Credentials', 'true')
    @exchange.response.setHeader(
      'Access-Control-Allow-Methods',
      @exchange.request.headers['Access-Control-Request-Method'] ?
      'GET,PUT,POST,HEADER')
  # by default send it as static content - browser caches forever
  static_file: (file_path) ->
    @exchange.request.filename = file_path if file_path
    @exchange.domain = 'client'
    @exchange.reply = (next) => @send_static(next)
    return @
  send_static: (next = ->) ->
    fs.stat name = @exchange.request.filename, (err, stats) =>
      name = dirs.normalise name
      name += '/' if stats?.isDirectory() and name.slice(-1) != '/'
      # gzip name, (error, zipped-name) =>
      #   @exchange.response.setHeader 'Content-Encoding', 'gzip'
      #   @set_mime_type name
      sender = send @exchange.request, path.resolve(name),
        maxAge: @exchange.environment.maximum_browser_cache_age,
        lastModified: true
      sender.req.res = @exchange.response # send bug
      sender.on('end', next).on('error', next)
      sender.pipe(@exchange.response)
  # respond to client with code to run in a sandbox
  client: (code) ->
    client = @exchange.request.filename
    return @script(clients[client]) if clients[client]
    url = @exchange.request.url.path
    options =
      template_name: 'templates/client.js'
      script: "(#{code.toString()})()\n"
      url: @exchange.request.url.pathname
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
      'public, max-age=#{@exchange.environment.maximum_browser_cache_age}'
    @exchange.response.setHeader 'content-length', text.length
    @exchange.response.end text
  # respond to client with some JSON for browser script consumption
  json: (data, replacer = null, space = '  ') ->
    @exchange.respond.set_mime_type 'json'
    @text JSON.stringify data, replacer, space
  # respond to client with some HTML for browser consumption
  html: (data...) ->
    @exchange.respond.set_mime_type 'html'
    @text data.join('')
  # string representation of data that changes on every request
  text: (text = '') ->
    @exchange.response.setHeader 'Cache-Control', 'public, no-cache'
    @exchange.response.setHeader 'content-length', text.length
    @exchange.response.end text
  # morph (compile) one language to another (usually javascriot or css)
  morph: (morph, next) ->
    morph @exchange.request.filename, (error, filename, changed) =>
      @exchange.request.filename = filename
      next error, @exchange
  # send back an error response to the client
  error: (reason, code = 500) ->
    @exchange.response.writeHead code, reason
    @exchange.response.end JSON.stringify error:reason
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
  # read post request into a string
  read_request: (next) ->
    # TODO: change to streams2
    data = []
    @exchange.request.on 'data', (chunk) -> data.push chunk
    @exchange.request.on 'end', -> next data.join ''
    @exchange.request.resume()

module.exports = (exchange) -> new Respond(exchange)
