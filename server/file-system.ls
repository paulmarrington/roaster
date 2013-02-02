# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'fs'; require! 'path'

# look in a file for a matching regular expression.
fs.contains = (name, pattern, next) ->
  fs.readFile name, 'utf8', (error, data) ~>
    matched = new RegExp(pattern).exec(data ? '')
    return next if matched.length is 0 then "#{pattern} not found"

# run a function with current working directory set - then set back afterwards
fs.in-directory = (to, action) ->
  cwd = process.cwd()
  try
    process.chdir to
    action()
  finally
    process.chdir cwd

# return file name relative to the node server directory
fs.node = (...names) -> path.join process.env.uSDLC_node_path, ...names

# return file name relative to the application base directory
fs.base = (...names) -> path.join process.env.uSDLC_base_path, ...names

# bases used to find relative address files
fs.bases = [process.env.uSDLC_base_path, process.env.uSDLC_node_path]

# find a file in node or base with (sometimes) implied extensions
fs.find = (name, next) ->
  find_one = (bases) ->
    return next(fs.base name) if bases.length is 0
    full_path = path.join bases.shift(), name
    fs.exists full_path, (exists) ->
      return next(full_path) if exists
      find_one(bases)
  find_one fs.bases.slice 0

module.exports = fs
