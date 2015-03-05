# Copyright (C) 2015 paul@marrington.net, see /GPL for license

class Open
  editor: (@container, ready) ->
    require.packages 'codemirror', =>
      ready()

module.exports = Open