# Copyright (C) 2013 Paul Marrington ('paul@marrington.net), see uSDLC2/GPL for license
require! morph;

module.exports = (ext, before, after) ->
  return (source, next) ->
    morph source, ext, (error, filename, contents, save) ->
      if contents
        save error, before + contents + after
      next error, filename
