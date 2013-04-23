# Copyright (C) 2013 paul@marrington.net, see GPL for license
steps = require 'steps';
morph = require 'morph'; path = require 'path'; dirs = require 'dirs'

module.exports = (source, css_created) ->

  load_libraries = -> @requires 'stylus'

  morph_stylus = -> morph source, '.css',
    @next (@error, @css_filename, @content, @write_css) =>

  render_css = ->
    if not @content then @skip(); return @next()  # up to date
    @stylus(@content).set('filename', @css_filename).
      set('paths', [path.dirname source, dirs.base()]).
        render @next (@error, @css) =>

  write = -> @write_css null, @css

  parsing_complete = -> css_created null, @css_filename

  steps(
    load_libraries
    morph_stylus
    render_css
    write
    parsing_complete
  )
