# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
template = require('server/http/ext/coffee').template
script_runner = require 'script-runner'

# script is uSDLC instrumentation - fork off a new V8 process to deal
module.exports = (exchange) ->
  template exchange, (filename) -> script_runner(exchange).fork filename
