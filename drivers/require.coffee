# Copyright (C) 2013 paul@marrington.net, see GPL for license
npm = require 'npm'; node_library = require 'node_library'
driver = require 'http/driver'; path = require 'path'
dirs = require 'dirs'

cache = {}

# supports require on the browser by retrieving modules
# local or remote (as in npm or node core source)
module.exports = (exchange, next, add_driver) ->
  add_driver 'client'
  exchange.is_module = true
  path_name = exchange.request.url.pathname
  if path_name[0] is '/'
    path_name = path_name[1..-1]
    exchange.request.url.pathname = path_name
  
  done = (module_path) ->
    if (dot = module_path.lastIndexOf('.')) isnt -1
      add_driver module_path.substring(dot + 1)
    exchange.request.filename =
      cache[path_name] = module_path
    next()
  return done(module) if module = cache[path_name]
  
  module_name = path_name.replace(/\.[^\/]*$/, '')
    
  try
    done require.resolve path.join 'client', module_name
  catch
    try
      module_path = require.resolve(module_name)
      module_path = dirs.normalise(module_path)
      slash = module_path.lastIndexOf('/')
      return done(module_path) if slash isnt -1
      node_library.resolve_built_in module_name,
        (err, module_path) -> done module_path
    catch
      on_err = ->
        console.log msg = "Failed to find #{module_name} for client"
        next msg
      try
        process.on 'uncaughtException', on_err
        npm module_name, (error, module) ->
          return done require.resolve module_name if not error
          console.log(error); return next(error)
      catch err then on_err()
      finally process.removeListener 'uncaughtException', on_err
