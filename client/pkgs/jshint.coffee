# Copyright (C) 2013-5 paul@marrington.net, see /GPL for license

module.exports = (loaded) ->
  require.dependency(
  jshint: 'https://raw.githubusercontent.com/jshint/jshint/master/dist/jshint.js|codemirror/jshint'
  '/ext/codemirror/jshint.js', loaded)
