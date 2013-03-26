# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
respond = require 'http/respond'; cache = {}; steps = require 'steps'
demand = require 'demand'; morph = require 'morph'

# Look for drivers to handle files of a specific file type.
# More than one extension means more than one driver to pipe through.

# The path search is also important. It first looks in the same directory
# then parents of the script. Lastly it will look in http/ext in
# the base system or the node server.

# If nothing else matches the file is assumed to be a static resource.
module.exports = (exchange) ->
  parts = exchange.request.filename.split '.'
  return exchange.respond.send_static() if parts.length is 1

  drivers = []; driver = null
  # we had to move the push into a function so that coffee-script
  # did not overwrite the reference to 'driver'
  add_driver = (name) ->
    if not (name of cache)
      try
        cache[name] = require "drivers/#{name}"
      catch error
        cache[name] = null
        demand.check_for_missing_requirement(name, error)
    if driver = cache[name]
      do (driver) ->
        drivers.push fn = -> driver(exchange, @next)
        fn.notes = "#{exchange.request.filename}: driver '#{name}'"
  # pull drivers from query string key 'domain' and file name extensions
  if query_drivers = exchange.request.url.query.domain
    for driver_name in query_drivers.split(',') then add_driver driver_name
  base_driver_length = drivers.length
  for driver_name in parts[1..] then add_driver driver_name
  if not driver
    exchange.respond.static_file()
    add_driver 'default' if drivers.length
  # default action is to run it on the server and let bygones be bygones
  exchange.reply ?= (next) ->
    try
      driver = require(exchange.request.filename)
      if driver.length > 1
        driver(exchange, next) # async
      else
        driver(exchange) # sync
        next()
    catch error
      console.log "Script failure: 
        '#{exchange.request.filename}' #{error.toString()}"
      next()
      throw error
  # run each driver in turn then fire off the response
  reply = -> exchange.reply @next
  reply.notes = "Driver reply for '#{exchange.request.filename}'"
  steps drivers..., reply

module.exports.use_template = (exchange, template, next) ->
  exchange.template = (file_name, on_completion) ->
    template = template.replace /\./, '_library.' if exchange.is_library
    options =
      script_name: file_name
      output_name: file_name
      script: file_name
      url: exchange.request.url.path
    steps(
      -> @requires 'templates', 'fs'
      -> @fs.find template, @next (found) => options.template_name = found
      -> @templates.process_file options, @next
      -> on_completion()
      )
  next()