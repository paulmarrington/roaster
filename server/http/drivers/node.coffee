# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
respond = require 'http/respond'
script_runner = require 'script-runner'
throwError = require('system').throwError

# script is uSDLC instrumentation - fork off a new V8 process to deal
module.exports = (exchange) ->
  exchange.domain = 'node'
  exchange.reply = (morph) ->
    respond.morphed exchange, morph, throwError  ->
      script_runner(exchange).fork()
