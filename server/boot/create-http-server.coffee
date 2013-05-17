# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
http = require 'http'; url = require 'url'; files = require 'files'
driver = require 'http/driver'; respond = require 'http/respond'
fs = require 'fs'; util = require 'util'

global.http_processors.push (exchange, next_processor) ->
  files.find exchange.request.url.pathname, (filename) ->
    filename ?= exchange.request.url.pathname
    try
      exchange.request.filename = filename
      # all the set up is done, process the request based on a driver
      # for file type. Some drivers cannot set mime type. For these we put it
      # in the query string as txt or text/plain.
      if exchange.request.url.query.mimetype
          exchange.respond.set_mime_type request.url.query.mimetype
      # kick off exchange
      driver(exchange)
    catch error
      errmsg = util.inspect error
      console.log errmsg
      exchange.response.write errmsg if environment.debug
      next_processor()  # try the next one since this one failed

global.http_processors.push (exchange, next_processor) ->
  exchange.response.end()

module.exports = (environment) ->
  return environment.server = http.createServer (request, response) ->
    console.log request.url if environment.debug
    request.pause()
    request.url = url.parse request.url, true
    # see if we want to restart in debug mode
    if request.url.query.restart and environment.debug
      if (new Date().getTime() - process.environment.since) > 5000
        response.end "<script>setTimeout('window.location.href = window.location.href', 2000)</script>"
        process.exit(0)
    # an exchange object that is passed to http processors
    exchange = { request, response, environment }
    exchange.respond = respond(exchange)
    # addresses can start with /!domains/absolute-path
    if request.url.pathname[1] == '!'
      slash = request.url.pathname.indexOf('/', 2)
      # query string domain takes precedence over /! source
      if not request.url.query.domain
        request.url.query.domain = request.url.pathname.slice 2, slash
      request.url.pathname = request.url.pathname.slice slash
    # run through all the http processors until one says 'all done'
    processors = global.http_processors.slice(0)
    do it = -> processors.shift()(exchange, it) if processors.length
