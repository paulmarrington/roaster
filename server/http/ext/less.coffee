# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
demand = require 'demand'; step = require 'step'
build = require 'code-builder'; respond = require 'http/respond'

module.exports = (exchange) ->
  write_css = null; css_filename = null; less = null
  step(
    ->
      demand 'less', this
    (error, less_reference) ->
      throw error if error
      less = less_reference
      build exchange.request.filename, '.css', this
    (error, filename, content, next) ->
      throw error if error
      return respond exchange, css_filename if not content  # up to date
      write_css = next
      css_filename = filename
      parser = new less.Parser
          paths: ['.'], # Specify search paths for @import directives
          filename: filename # Specify a filename, for better error messages
      parser.parse content, this
    (error, tree) ->
      throw error if error
      css = tree.toCSS compress: true
      write_css(null, css)
      respond exchange, css_filename
  )
