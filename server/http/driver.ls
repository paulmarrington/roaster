# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'http/respond'; require! 'path'
require! 'drivers/server'; require! 'drivers/client'
cache = {}

# Look for drivers to handle files of a specific file type.
# More than one extension means more than one driver to pipe through.

# The path search is also important. It first looks in the same directory
# then parents of the script. Lastly it will look in http/ext in
# the base system or the node server.

# If nothing else matches the file is assumed to be a static resource.
module.exports = driver = (exchange) ->
  pathname = exchange.request.filename
  possible-drivers = path.basename(pathname).split('.').slice(1)
  if domain = exchange.request.url.query.domain
    possible-drivers = possible-drivers.concat domain.split('.')
  # no extension - let static return index.html
  return exchange.respond.static! if possible-drivers.length is 0

  # any dir can have a drivers sub-dir with index.js
  possible-drivers.unshift 'index'
  # drivers can be on the same or parent path as the script being run
  # or in [node|base]/server/http/ext.
  script-path = path.relative process.cwd, path.dirname pathname
  if cache[script-path]
    possible-paths = cache[script-path]
  else
    possible-paths = ['']
    while (slash = (script-path.lastIndexOf('/') - 1)) > 0
      possible-paths.push script-path
      script-path = script-path[0 to slash]
    possible-paths.push script-path
    cache[script-path] = possible-paths

  # search all paths in cache and on disk (require) before
  # searching for next driver name. Otherwise a cached
  # more generic driver may be incorrectly returned
  drivers = []; core-driver-found = false;
  driver-mapping = {}; possible-driver = ''
  while possible-drivers.length
    possible-driver = possible-drivers.shift!
    # process any driver mapping
    while mapped = driver-mapping[possible-driver]
      possible-drivers ++= mapped
      possible-driver = possible-drivers.shift!
    # first lets look for cached copies from a previous require
    module-names = []; found = null
    for possible-path in possible-paths
      module-name = path.join possible-path, 'drivers', possible-driver
      if module-name of cache
        if cache[module-name]
          drivers.push that
          for inferred in module-names then cache[inferred] = that
          found = module-name
        # index is special - all on path are loaded
        break if module-name isnt 'index'
      else
        module-names.push module-name
    if not found # nothing cached - require until we get it or fail all paths
      tried = []; driver-module = null
      for module-name in module-names
        try
          # we can cache it as the first possibility because it doesn't happen otherwuse
          # and it makes subsequent lookups faster
          tried.push module-name
          drivers.push driver-module = require module-name
          found = module-name
          # split any driver maps into a list of drivers
          map = driver-module.driver-mapping ? {}
          driver-module.driver-mapping =
            {[key, value.split '.'] for key, value of map}
          # index is special - all on path are loaded
          break if module-name isnt 'index'
        catch error
          # error can be in required code or because code does not exist
          throw error if error.code isnt 'MODULE_NOT_FOUND'
          # must check it is the asked for not found, not inner require
          throw error if error.toString().indexOf("#possible-driver'") is -1
      # so we never check again on failures
      for inferred in tried then cache[inferred] = driver-module
    if found and cache[found] # we looked and the driver exists
      core-driver-found = true if not possible-drivers.length
      driver-mapping <<< cache[found].driver-mapping
  # There is no driver module for this extension. Default to a static
  # driver. Save it as the first in the cache to make the next time it
  # is asked for very fast.
  if not core-driver-found
    for possible-path in possible-paths
      module-name = path.join possible-path, 'drivers', possible-driver
      cache[module-name] = null
    return exchange.respond.static!

  # and the one ring brings them all together
  drivers.push (exchange) ->
    exchange.respond.set-mime-type exchange.response.mimetype ? 'js'
    # if we don't have a domain from drivers, default
    # to a servlet if there is a query, client if empty query string.
    # over-ride with query domain=(client|server)
    if not exchange.domain
      # use search as query dictionary length is expensive to calculate
      if exchange.request.url.search.length < 2
        then client exchange else server exchange
    # and send a reply based on all the instructions
    exchange.reply exchange.morph

  # If a driver has one parameter (exchange object) then it is
  # synchronous. Otherwise it is asynchronous and will call the
  # second parameter when done.
  drive = ->
    # loop through drivers to end or first asynchronous call
    while drivers.length isnt 0
      driver = drivers.shift()
      exchange.last-driver = not drivers.length
      # async - run and only continue on completion
      return driver(exchange, drive) if driver.length >= 2
      # synd - do it straight away and go on to next one
      driver(exchange)
  drive!
