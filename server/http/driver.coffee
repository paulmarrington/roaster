# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
static_driver = require('http/respond').static
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
  last_driver = possible_drivers[possible_drivers.length - 1]
  possible_drivers.push 'index'

  # drivers can be on the same or parent path as the script being run
  # or in [node|base]/server/http/ext.
  script_path = path.relative process.cwd, path.dirname pathname
  if cache[script_path]
    possible_paths = cache[script_path]
  else
    possible_paths = []
    while (slash = (script_path.lastIndexOf('/') - 1)) > 0
      possible_paths.push script_path
      script_path = script_path[0..slash]
    possible_paths.push script_path
    possible_paths.push 'http'

  # search all paths in cache and on disk (require) before
  # searching for next driver name. Otherwise a cached
  # more generic driver may be incorrectly returned
  drivers = []; core_driver_found = false
  for possible_driver in possible_drivers
    # first lets look for cached copies from a previous require
    module_names = []; found = null
    for possible_path in possible_paths
      module_name = path.join possible_path, 'drivers', possible_driver
      if cache[module_name]
        found = drivers.push cache[module_name]
        cache[inferred] = found for inferred in module_names
        found = module_name
        break
      module_names.push module_name
    if not found # nothing cached - require until we get it or fail all paths
      tried = []
      for module_name in module_names
        try
          # we can cache it as the first possibility because it doesn't happen otherwuse
          # and it makes subsequent lookups faster
          tried.push module_name
          drivers.push driver_module = require module_name
          found = module_name
          cache[inferred] = driver_module for inferred in tried
          break
        catch error
          throw error if error.code isnt 'MODULE_NOT_FOUND'
          throw error if error.toString().indexOf(possible_driver) is -1
    core_driver_found = true if found and possible_driver is last_driver

  # There is no driver module for this extension. Default to a static
  # driver. Save it as the first in the cache to make the next time it
  # is asked for very fast.
  if not core_driver_found
    for possible_path in possible_paths
      module_name = path.join possible_path, 'drivers', last_driver
      cache[module_name] = static_driver
    return static_driver

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
