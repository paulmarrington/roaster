# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
npm = require 'npm'; node_library = require 'node_library'
driver = require 'http/driver'

# supports require on the browser by retrieving modules - local or remote
module.exports = (exchange, next) ->
  module_name = exchange.request.url.pathname.replace(/\..*$/, '')[1..]
  done = (module_path) ->
    exchange.respond.static_file module_path
    next()

  if not (module_path = require.resolve module_name)
    npm module_name, (error, module) ->
      if error
        console.log error
        return next()
      done require.resolve module_name
  else if module_path.indexOf('/') is -1
    node_library.resolve_built_in module_name, (module_path) -> done module_path
  else
    done module_path
