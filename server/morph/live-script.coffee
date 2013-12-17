# Copyright (C) 2013 paul@marrington.net, see /GPL for license
morph = require 'morph'; livescript = require 'LiveScript'

module.exports = (source, next) ->
  morph.compileJavascript source, livescript, next
