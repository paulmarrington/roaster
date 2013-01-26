# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
static_driver = require('http/respond').static; domain = require 'http/domain'
path = require 'path'; fs = require 'file-system'
cache = {}

# Look for drivers to handle files of a specific file type.
# More than one extension means more than one driver to pipe through.

# The path search is also important. It first looks in the same directory
# then parents of the script. Lastly it will look in http/ext in
# the base system or the node server.

# If nothing else matches the file is assumed to be a static resource.
module.exports = driver = (pathname) ->
  possible_drivers = path.basename(pathname).split('.').slice(1)
  # no extension - let static return index.html
  return static_driver if possible_drivers.length is 0

  # drivers can be on the same or parent path as the script being run
  # or in [node|base]/server/http/ext.
  possible_paths = []
  script_path = path.relative process.cwd, path.dirname pathname
  while (slash = (script_path.lastIndexOf('/') - 1)) > 0
    possible_paths.push script_path
    script_path = script_path[0..slash]
  possible_paths.push script_path
  possible_paths.push 'http/ext'

  # search all paths in cache and on disk (require) before
  # searching for next driver name. Otherwise a cached
  # more generic driver may be incorrectly returned
  drivers = []
  for possible_driver in possible_drivers
    # first lets look for cached copies from a previous require
    module_names = []
    for possible_path in possible_paths
      module_name = path.join possible_path, possible_driver
      drivers.push cache[module_name] if cache[module_name]
      module_names.push module_name
    # nothing cached - require until we get it or fail all paths
    tried = []  # save failures for caching
    for module_name in module_names
      try
        # we can cache it as the first possibility because it doesn't happen otherwuse
        # and it makes subsequent lookups faster
        tried.push module_name
        drivers.push driver_module = require module_name
        cache[inferred] = driver_module for inferred in tried
      catch error

  # There is no driver module for this extension. Default to a static
  # driver. Save it as the first in the cache to make the next time it
  # is asked for very fast.
  if drivers.length is 0
    cache[inferred] = static_driver for inferred in tried
    return static_driver

  # close off driver stream and send results on their way
  drivers.push (exchange) ->
    domain.set exchange
    exchange.reply exchange.morph

  # returns a function that runs each driver sequentially. If
  # a driver has one parameter (exchange object) then it is
  # synchronous. Otherwise it is asynchronous and will call the
  # second parameter when done.
  return (exchange) ->
    drive = ->
      while drivers.length isnt 0
        driver = drivers.shift()
        if driver.length >= 2
          return driver(exchange, drive)
        else
          driver(exchange)  # sunchronous call
    drive()
