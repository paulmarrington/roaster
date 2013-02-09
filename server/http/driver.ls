# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'http/respond'
cache = {}

# Look for drivers to handle files of a specific file type.
# More than one extension means more than one driver to pipe through.

# The path search is also important. It first looks in the same directory
# then parents of the script. Lastly it will look in http/ext in
# the base system or the node server.

# If nothing else matches the file is assumed to be a static resource.
module.exports = (exchange) ->
  dot = exchange.request.filename.lastIndexOf('.') + 1
  return exchange.respond.send-static() if not dot

  driver-name = exchange.request.filename.substring(dot)
  if not (driver-name of cache)
    try
      driver-module = require "drivers/#driver-name"
    catch error
      # error can be in required code or because code does not exist
      throw error if error.code isnt 'MODULE_NOT_FOUND'
      # must check it is the asked for not found, not inner require
      throw error if error.toString().indexOf("#driver-name'") is -1
    cache[driver-name] = driver-module
  driver-module = cache[driver-name]

  return exchange.respond.send-static() if not driver-module

  # default action is to run it on the server and let bygones be bygones
  exchange.reply = -> require(exchange.request.filename)(exchange)

  next = ->
    exchange.respond.set-mime-type exchange.response.mimetype ? 'js'
    exchange.reply()

  if driver-module.length >= 2
    driver-module(exchange, next)
  else # sync - do it straight away and go on to next one
    driver-module(exchange)
    next()
