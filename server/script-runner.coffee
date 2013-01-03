# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
child = require 'child_process'; Processes = require 'Processes'
set_mime_type = require('http/respond').set_mime_type

class Script_Runner
  constructor: (@exchange) ->
    @proc = Processes().resume -> @exchange.response.end()
    # Output will be wiki text as written by stdout and stderr
    set_mime_type 'plain.txt', @exchange.response
    url = @exchange.request.url
    @args = [url.pathname, url.query, url.hash]
    @proc.options.stdio = ['ignore', @exchange.response, @exchange.response]
    
  # Fork off a separate node process to run the V8 scripts in a separate space
  fork: (script) -> # require('Script-Runner')(request, response).fork(program) 
    @proc.fork "#{process.env.uSDLC_node_path}/scripts/coffee.js", [script, args...]
  
  # require('Script-Runner')(request, response).spawm(program) 
  spawn: (program) -> @proc.spawn program, args... # Spawn off a separate OS process

module.exports = (exchange) -> new Script_Runner(exchange)