# Copyright (C) 2012 paul@marrington.net, see GPL for license
npm = require 'npm'; morph = require 'morph'
path = require 'path'; dirs = require 'dirs'

module.exports = (source, css_created) ->
  npm 'less',(error, less) ->
    return css_created(error) if error
    morph source, '.css', (err, name, content, writer) ->
      return css_created(null, name) if not content
      try less.render(content,
        # Specify search paths for @import directives
        paths: [path.dirname source, dirs.base()]
        relativeUrls: true
        # Specify a filename, for better error messages
        filename: name
      ).then(
        ((output) -> writer null, output.css; css_created null, name),
        ((err) -> css_created(error))
      ) catch err
        css_created err
