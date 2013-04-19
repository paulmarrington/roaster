# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see GPL for license
steps = require 'steps';
morph = require 'morph'; path = require 'path'; dirs = require 'dirs'

module.exports = (source, css_created) ->

  load_libraries = -> @requires 'less'

  process_less = -> morph source, '.css',
    @next (@error, @css_filename, @content, @write_css) =>

  convert_to_parse_tree = ->
    return @next() if not @content  # up to date
    new @less.Parser(
      # Specify search paths for @import directives
      paths: [path.dirname source, dirs.base()]
      relativeUrls: true
      # Specify a filename, for better error messages
      filename: @css_filename
    ).parse @content, @next (@error, @tree) =>

  convert_to_css = ->
    return if not @tree
    css = @tree.toCSS compress: true
    @write_css null, css

  parsing_complete = -> css_created null, @css_filename

  steps(
    load_libraries
    process_less
    convert_to_parse_tree
    convert_to_css
    parsing_complete
  )
