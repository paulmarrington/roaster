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
  return static_driver if not dot

  # my_file.view.coffee can have drivers view.coffee or coffee
  possible_drivers = [ext = basename[dot..]]
  while dot = (ext.indexOf('.') + 1)
    possible_drivers.push ext = ext[dot..]

  # drivers can be on the same path as the script being run or
  # in [node|base]/server/http/ext. The former is for micro-apps
  # while the latter for global drivers.
  driver = path.relative process.cwd, path.dirname pathname
  possible_paths = []
  while (slash = (driver.lastIndexOf('/') - 1)) > 0
    possible_paths.push driver
    driver = driver[0..slash]
  possible_paths.push driver
  possible_paths.push 'http/ext'

  # expand possibilities into a single list and;
  # See if a possibility is already in the requires cache
  possibilities = []
  for possible_path in possible_paths
    for possible_driver in possible_drivers
      module_name = path.join possible_path, possible_driver
      return cache[module_name] if cache[module_name]
      possibilities.push module_name

  # This modile has never been loaded before. Get require to look
  # on disk and load it if found
  for possibility in possibilities
    try
      return cache[possibility] = require possibility
    catch error

  # There is no driver module for this extension. Default to a static
  # driver. Save it as the first in the cache to make the next time it
  # is asked for very fast.
  return require.cache[possibilities[0]] = static_driver