# Copyright (C) 2013-5 paul@marrington.net, see /GPL for license

module.exports = (loaded) ->
  require.dependency(
    coffeelint: 'http://www.coffeelint.org/js/coffeelint.js|codemirror/coffeelint'
    '/ext/codemirror/coffeelint.js', loaded)
