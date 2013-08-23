# Copyright (C) 2013 paul@marrington.net, see GPL for license
npm = require 'npm'; node_library = require 'node_library'
driver = require 'http/driver'

# supports require on the browser by retrieving modules
# local or remote (as in npm or node core source)
module.exports = (exchange, next) ->
  path_name = exchange.request.url.pathname
  module_name = path_name.replace(/\..*$/, '')[1..]
  
  done = (module_path) ->
    exchange.respond.static_file module_path
    next()

  try
    module_path = require.resolve module_name
    if module_path.indexOf('/') isnt -1
      return done(module_path) # in mode_modules
    node_library.resolve_built_in module_name,
      (module_path) -> done module_path
  catch err
    npm module_name, (error, module) ->
      if error
        console.log error
        return next()
      done require.resolve module_name
