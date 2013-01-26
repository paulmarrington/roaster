# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
path = require 'path'; morph = require 'morph'
livescript = require 'LiveScript'; step = require 'step'

module.exports = (source, next) ->
  morph source, '.js', (error, filename, content, save) ->
    return next(error, filename) if error
    if content
      js = livescript.compile content
      save null, js, (error) -> return next(error, filename)
    else
      next(null, filename)
# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
morph = require 'morph'; livescript = require 'LiveScript'

module.exports = (source, next) ->
  morph.compileJavascript source, livescript, next
