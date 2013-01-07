# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
morph = require('morph/coffee'); script_runner = require 'script-runner'
throw_error = require('system').throw_error

# script is uSDLC instrumentation - fork off a new V8 process to deal
module.exports = (exchange) ->
  respond.morphed exchange, morph, throw_error  -> 
    script_runner(exchange).fork()
