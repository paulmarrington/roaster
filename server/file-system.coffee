# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
fs = require 'fs'

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

module.exports = fs