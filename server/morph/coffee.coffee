# Copyright (C) 2013 paul@marrington.net, see /GPL for license
morph = require 'morph'; coffee = require 'coffee-script'

module.exports = (source, next) ->
  morph.compileJavascript source, coffee, next
