# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
static_driver = require('http/respond').static;
path = require 'path'; fs = require 'file-system'
cache = {}

# This load if twisted doodoo looks for a driver to handle files of a
# specific file type - bein the text after the first dot in the file-name.
# It will also look for sub-sets where the file type has more than one
# section separated by dots. Example: model.coffee will first look for
# a driver model.coffee and then for one called coffee.

# The path search is also important. It first looks in the same directory
# as the file requiring a driver. It then looks in all parent directories.
# Lastly it will look in http/ext is any the server directory in either
# the base system or the node server.

# If nothing else matches the file is assumed to be a static resource.
module.exports = driver = (pathname) ->
  basename = path.basename pathname
  dot = basename.indexOf('.') + 1
  # no dots - let static return index.html
  return static_driver if not dot

  # let's shortcut the calculations for already loaded drivers
  first_driver = ext = basename[dot..]
  first_path = path.relative process.cwd, path.dirname pathname
  first_module_name = path.join first_path, first_driver
  return cache[first_module_name] if cache[first_module_name]

  # my_file.view.coffee can have drivers view.coffee or coffee
  possible_drivers = [first_driver]
  while dot = (ext.indexOf('.') + 1)
    possible_drivers.push ext = ext[dot..]

  # drivers can be on the same path as the script being run or
  # in [node|base]/server/http/ext. The former is for micro-apps
  # while the latter for global drivers.
  possible_paths = []
  while (slash = (first_path.lastIndexOf('/') - 1)) > 0
    possible_paths.push first_path
    first_path = first_path[0..slash]
  possible_paths.push first_path
  possible_paths.push 'http/ext'

  # search all paths in cache and on disk (require) before
  # searching for next driver name. Otherwise a cached
  # more generic driver may be incorrectly returned
  for possible_driver in possible_drivers
    # first lets look for cached copies from a previous require
    module_names = []
    for possible_path in possible_paths
      module_name = path.join possible_path, possible_driver
      return cache[module_name] if cache[module_name]
      module_names.push module_name
    # nothing cached - require until we get it or fail all paths
    for module_name in module_names
      try
        # we can cache it as the first possibility because it doesn't happen otherwuse
        # and it makes subsequent lookups faster
        cache[first_module_name] = cache[module_name] = require module_name
        return cache[module_name]
  #      return cache[pfirst_module_name] = cache[module_name] = require module_name

      catch error

  # There is no driver module for this extension. Default to a static
  # driver. Save it as the first in the cache to make the next time it
  # is asked for very fast.
  return cache[first_module_name] = static_driver