# Copyright (C) 2013 paul@marrington.net, see GPL for license
respond = require 'http/respond'; cache = {}
npm = require 'npm'; morph = require 'morph'
path = require 'path'; _ = require 'underscore'
templates = require 'templates'; files = require 'files'

# Look for drivers to handle files of a specific file type.
# More than one extension means more than one driver to pipe
# through. The path search is also important. It first looks
# in the same directory then parents of the script. Last it
# will look in http/ext in the base system or the node server.
# If nothing else matches the file is assumed to be a
# static resource.
module.exports = (exchange) ->
  parts = exchange.request.filename.split '.'
  return exchange.respond.send_static() if parts.length is 1

  drivers = []; driver = null
  exchange.template = (next) -> next()  # default does nothing
  # we had to move the push into a function so that
  # coffee-script did not overwrite the reference to 'driver'
  add_driver = (name) ->
    if not (name of cache)
      try
        cache[name] = require "drivers/#{name}"
      catch error
        cache[name] = null
        npm.check_for_missing_requirement(name, error)
    if driver = cache[name]
      do (driver) ->
        drivers.push fn = (next) ->
          driver(exchange, next, add_driver)
        fn.notes =
          "#{exchange.request.filename}: driver '#{name}'"
  # pull drivers from query string key 'domain'
  # and file name extensions
  if query_drivers = exchange.request.url.query.domain
    for driver_name in query_drivers.split(',')
      add_driver driver_name
  base_driver_length = drivers.length
  add_driver(driver_name) for driver_name in parts[1..]
  exchange.respond.static_file() if not driver
  # default action is to run it on the server and let
  # bygones be bygones
  exchange.reply ?= (next) ->
    try
      driver = require(exchange.request.filename)
    catch error
      console.log error.toString()
      exchange.respond.error(
        "No #{exchange.request.url.href}", 404)
      return next()
    try
      if driver.length > 1
        driver(exchange, next) # async
      else
        driver(exchange) # sync
        next()
    catch error
      console.log """Script failure:
        \t#{exchange.request.filename}
        \t#{error.toString()}"""
      next()
      throw error
  # run each driver in turn then fire off the response
  do run_driver = ->
    if not drivers.length
      return exchange.template -> exchange.reply ->
    drivers.shift()(run_driver)

module.exports.use_template = (exchange, template, next) ->
  exchange.template = (next_template) ->
    apply_template = (source, template_applied) ->
      # templates only valid if domain matches source types
      if path.extname(source) isnt path.extname(template)
        return template_applied(null, source, false)
      if exchange.is_library
        template = template.replace /\./, '_library.'
      ext = ".#{path.basename template}"
      morph source, ext, (error, filename, content, save) ->
        return next(error, filename) if error
        url = exchange.request.url.pathname.split('.')[0]
        url = url[1..-1] if url[1] is '/'
        if content
          options =
            script: content, url: url, template_name: template
            key: path.basename(exchange.request.url.pathname).
                 split('.')[0]
          options = _.extend options,
            exchange.request.url.query
          # set template or abort merge if no template
          templates.process_text options, (merged) ->
            save(null, merged) if merged
            template_applied(null, filename, not not merged)
        else
          template_applied(null, filename, false)
    exchange.respond.morph apply_template, next_template
  next()
