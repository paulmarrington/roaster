# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
morph = require morph; kaffeine = require "kaffeine"

module.exports = (source, next) ->
  # morph.compileJavascript source, kaffeine.fn, next
  compiler =
    compile: (content, options) ->
      k = new kaffeine()
      # uglify-opts = (uglify|beautify|null)
      return k.compile content
  morph.compileJavascript source, compiler, next
