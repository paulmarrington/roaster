# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
demand = require 'demand'; step = require 'step'; morph = require 'morph'
fs = require 'file-system'; path = require 'path'

module.exports = (source, next) ->
  write_css = null; css_filename = null; less = null
  step(
    ->
      demand 'less', this
    (error, less_reference) ->
      throw error if error
      less = less_reference
      morph source, '.css', this
    (error, filename, content, save) ->
      return next(error, filename) if error
      return next(null, filename) if not content  # up to date
      write_css = save
      css_filename = filename
      # we have less @imports search from base path and the path
      # if this file (the one being included from)
      rel_dir = path.dirname source
      parser = new less.Parser
          paths: [rel_dir, fs.base()], # Specify search paths for @import directives
          filename: filename # Specify a filename, for better error messages
      parser.parse content, this
    (error, tree) ->
      return next(error, css_filename) if error
      css = tree.toCSS compress: true
      write_css(null, css)
      next null, css_filename
  )
