# Copyright (C) 2013 Paul Marrington ('paul@marrington.net), see uSDLC2/GPL for license
require! morph; require! 'coffee-script'

module.exports = (source, next) ->
  morph.compileJavascript source, coffee-script, next
