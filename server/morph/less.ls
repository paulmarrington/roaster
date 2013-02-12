# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! demand; require! step; require! morph; require! path; require! fs

module.exports = (source, next) ->
  var write_css, css_filename, less
  step(
    ->
      demand 'less', @next
    (error, less_reference) ->
      less := less_reference
      morph source, '.css', @next
    (error, filename, content, save) ->
      # return next(error, filename) if error
      return next(null, filename) if not content  # up to date
      write_css := save
      css_filename := filename
      # we have less @imports search from base path and the path
      # if this file (the one being included from)
      new less.Parser(
        # Specify search paths for @import directives
        paths: [path.dirname source, fs.base()]
        # Specify a filename, for better error messages
        filename: filename
      ).parse content, @next
    (error, tree) ->
      return next(error, css_filename) if error
      css = tree.toCSS compress: true
      write_css null, css
      next null, css_filename
  )
