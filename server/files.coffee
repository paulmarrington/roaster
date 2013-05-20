# Copyright (C) 2012,13 paul@marrington.net, see GPL for license
fs = require 'fs'; path = require 'path'; dirs = require 'dirs'

module.exports =
  # returns a file on one path or null if it can't be found
  # next(full_path, base_path, rest)
  find: (name, next) ->
    find_one = (bases) ->
      return next() if bases.length is 0
      full_path = path.join (base = bases.shift()), name
      return find_one(bases) if full_path is '/'
      fs.exists full_path, (exists) ->
        return next(full_path, base, name) if exists
        find_one(bases)
    find_one dirs.bases.slice(0)

  copy: (source, target, next) ->
    done = (error = null) -> next error; done = ->
    input = fs.createReadStream(source).on 'error', done
    output = fs.createWriteStream(target).on('error', done).on('close', done)
    input.pipe output
