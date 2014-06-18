# Copyright (C) 2013-4 paul@marrington.net, see GPL for license
http = require 'http'; url = require 'url'
files = require 'files'; driver = require 'http/driver'
respond = require 'http/respond'
fs = require 'fs'; util = require 'util'
querystring = require 'querystring'
sessions = require './sessions'

global.http_processors.push (exchange, next_processor) ->
  files.find exchange.request.url.pathname, (filename) ->
    exchange.request.url.exists = filename
    filename ?= exchange.request.url.pathname
    try
      exchange.request.filename = filename
      # all the set up is done, process the request based
      # on a driver for file type. Some drivers cannot set
      # mime type. For these we put it
      # in the query string as txt or text/plain.
      if exchange.request.url.query.mimetype
        exchange.respond.set_mime_type(
          request.url.query.mimetype)
      # kick off exchange
      driver(exchange)
    catch error
      console.log error.stack
      if process.environment.debug
        exchange.response.write error.stack
      # try the next one since this one failed
      next_processor()

global.http_processors.push (exchange, next_processor) ->
  exchange.response.end()

module.exports = (environment) ->
  return environment.http_server =
  http.createServer (request, response) ->
    console.log request.url if environment.debug
    request.url = url.parse request.url, true
    # see if we want to restart in debug mode
    if request.url.query.restart and environment.debug
      if (new Date().getTime() - process.environment.since) > 5000
        response.end(
          "<script>setTimeout('window.location.href = "+
          "window.location.href', 2000)</script>")
        process.exit(0)
    # client wants to know what services are available
    if request.method is 'OPTIONS'
      response.setHeader 'Allow', 'GET, PUT'
      return response.end()
    # integrate post data into the query string
    request.post = (parser, next) ->
      if not next
        next = parser
        parser = querystring.parse
      return false if request.method isnt 'POST'
      body = []
      request.on 'readable', ->
        body.push data while (data = request.read()) isnt null
      request.on 'end', ->
        try next null, parser body.join('')
        catch err then next err
      return true
    session = sessions(request, response)
    # an exchange object that is passed to http processors
    exchange = { request, response, environment, session }
    exchange.respond = respond(exchange)
    # addresses can start with /!domains/absolute-path
    if request.url.pathname[1] == '!'
      slash = request.url.pathname.indexOf('/', 2)
      # query string domain takes precedence over /! source
      if not request.url.query.domain
        request.url.query.domain = request.url.pathname.slice 2, slash
      request.url.pathname = request.url.pathname.slice slash
    # run through all the http processors until one says 'all done'
    processors = global.http_processors.slice(0) # clone
    do it = -> processors.shift()(exchange, it) if processors.length
