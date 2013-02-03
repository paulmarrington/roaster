# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require 'script-runner'; require! system.throw-error

# script is uSDLC instrumentation - fork off a new V8 process to deal
module.exports = (exchange) ->
  exchange.domain = 'node'
  exchange.reply = (morph) ->
    exchange.respond.morphed morph, throw-error  ->
      script-runner(exchange).fork()
