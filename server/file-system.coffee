# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
fs = require 'fs'; path = require 'path'

# look in a file for a matching regular expression. 
fs.contains = (name, pattern, next) ->
  fs.readFile name, 'utf8', (error, data) =>
    match = new RegExp(pattern).exec(data ? '')
    return next if match.length is 0 then "#{pattern} not found"

# run a function with current working directory set - then set back afterwards
fs.in_directory = (to, action) ->
  cwd = process.cwd()
  try
    process.chdir(to)
    action()
  finally
    process.chdir(cwd)

# return file name relative to the node server directory
fs.node = (name) -> path.join process.env.uSDLC_node_path, name

# return file name relative to the application base directory
fs.base = (name) -> path.join process.env.uSDLC_base_path, name

# bases used to find relative address files
fs.bases = [process.env.uSDLC_base_path, process.env.uSDLC_node_path]

# find a file in node or base with (sometimes) implied extensions
fs.find = (name) ->
  for base in fs.bases
    full_path = path.join base, name
    return full_path if fs.exists(full_path)
  return fs.base name

module.exports = fs