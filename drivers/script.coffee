# Copyright (C) 2013 paul@marrington.net, see GPL for license
driver = require 'http/driver'; npm = require 'npm'

cache = {}

module.exports = (exchange, on_completion, add_driver) ->
  path_name = exchange.request.url.pathname
  if path_name[0] is '/'
    path_name = path_name[1..-1]
    exchange.request.url.pathname = path_name
    
  done = (module_path) ->
    dot = module_path.lastIndexOf('.')
    add_driver module_path.substring(dot + 1) if dot isnt -1
    exchange.request.filename = cache[path_name] = module_path
    on_completion()
  return done(module) if module = cache[path_name]
  
  module_name = path_name.replace(/\.[^\/]*$/, '')

  try
    done require.resolve module_name
  catch then npm module_name, (error, module) ->
    done require.resolve module_name if not error
    console.log(error); return on_completion(error)
