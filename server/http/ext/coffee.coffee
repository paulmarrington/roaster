# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
path = require 'path'; build = require 'code-builder'
script_runner = require 'script-runner'; step = require 'step'
respond = require 'http/respond'

template = (exchange, send_response) ->
  step(
    ->
      build exchange.request.filename, '.js', this
    (error, filename, content, next) ->
      throw error if error
      if content
        js = coffee.compile content
        next null, js
      send_response(filename)
  )

module.exports = (exchange) ->
  template exchange, (filename) ->
    if exchange.request.filename.indexOf('/client/') isnt -1
      # script is to be run on the client - send back compiled version
      respond(exchange, filename)
    else if exchange.request.filename.indexOf('/usdlc/') isnt -1
      # script is uSDLC instrumentation - fork off a new V8 process to deal
      script_runner(exchange).fork filename
    else
      # script is to be run on the server, load using require
      require(filename)(exchange)

module.exports.template = template