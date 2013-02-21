# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
morph = require 'morph'; zlib = require 'zlib'

module.exports = (source, next) ->
  morph source, '.gzip', (error, filename, content, save) ->
    if content
      zlib.gzip content, (error, zipped) ->
        throw error if error
        save null, zipped
        next(null, filename)
      return
    next(null, filename) # todo: implement
