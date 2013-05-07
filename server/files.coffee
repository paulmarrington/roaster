# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
fs = require 'fs'; path = require 'path'; dirs = require 'dirs'

module.exports =
  # returns a file on one path or null if it can't be found
  find: (name, next) ->
    find_one = (bases) ->
      return next() if bases.length is 0
      full_path = path.join bases.shift(), name
      fs.exists full_path, (exists) ->
        return next(full_path) if exists
        find_one(bases)
    find_one dirs.bases.slice 0

  copy: (source, target, next) ->
    done = (error = null) -> next error; done = ->
    input = fs.createReadStream(source).on 'error', done
    output = fs.createWriteStream(target).on('error', done).on('close', done)
    input.pipe output
