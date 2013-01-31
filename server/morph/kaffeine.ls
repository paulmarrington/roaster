# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! morph; require! "kaffeine"

module.exports = (source, next) ->
  # morph.compileJavascript source, kaffeine.fn, next
  compiler =
    compile: (content, options) ->
      k = new kaffeine()
      # uglify-opts = (uglify|beautify|null)
      k.compile content, null, options.filename
  morph.compileJavascript source, compiler, next
