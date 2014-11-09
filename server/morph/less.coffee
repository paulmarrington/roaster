# Copyright (C) 2012 paul@marrington.net, see GPL for license
npm = require 'npm'; morph = require 'morph'
path = require 'path'; dirs = require 'dirs'

module.exports = (source, css_created) ->
  npm 'less',(error, less) ->
    return css_created(error) if error
    morph source, '.css', (err, name, content, writer) ->
      return css_created(null, name) if not content
      try new less.Parser(
        # Specify search paths for @import directives
        paths: [path.dirname source, dirs.base()]
        relativeUrls: true
        # Specify a filename, for better error messages
        filename: name
      ).parse content, (error, tree) ->
        return css_created(error) if error
        writer null, tree.toCSS compress: false
        css_created null, name
      catch err
        css_created err
