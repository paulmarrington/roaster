# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
npm = require 'npm'; node_library = require 'node_library'

# supports require on the browser by retrieving modules - local or remote
module.exports = (exchange) ->
  module_name = exchange.request.url.query.module

  if not (module_path = require.resolve module_name)
    npm module_name, (error, module) ->
      if error
        console.log error
        return exchange.response.end(error.toString())
      exchange.respond.static_file require.resolve module_name
  else if module_path.indexOf('/') is -1
    node_library.resolve_built_in module_name, (module_path) ->
      exchange.respond.static_file module_path
  else
    exchange.respond.static_file module_path
