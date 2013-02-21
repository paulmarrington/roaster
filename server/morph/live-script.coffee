# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
morph = require 'morph'; livescript = require 'LiveScript'

module.exports = (source, next) ->
  morph.compileJavascript source, livescript, next
