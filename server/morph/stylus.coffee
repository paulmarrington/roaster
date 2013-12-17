# Copyright (C) 2013 paul@marrington.net, see GPL for license
morph = require 'morph'; path = require 'path'
dirs = require 'dirs'; requires = require 'requires'

module.exports = (source, css_created) ->
  requires 'stylus', (error, stylus) ->
    return css_created(error) if error
    morph source, '.css', (err, name, content, writer) ->
      return css_created(null, name) if not content
      stylus(content).set('filename', name).
      set('paths', [path.dirname source, dirs.base()]).
      render (error, css) ->
        return css_created(error) if err
        writer null, css
        css_created(null, name)