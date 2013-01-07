# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
path = require 'path'; morph = require 'morph'
coffee = require 'coffee-script'; step = require 'step'

module.exports = (source, next) ->
  step(
    ->
      morph source, '.js', this
    (error, filename, content, save) ->
      return next(error, filename) if error
      if content
        js = coffee.compile content
        save null, js
      next(null, filename)
  )
