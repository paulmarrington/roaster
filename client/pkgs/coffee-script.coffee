# Copyright (C) 2013-5 paul@marrington.net, see /GPL for license

module.exports = (loaded) ->
  require.dependency(
    coffeescript: 'https://raw.githubusercontent.com/'+
    'jashkenas/coffee-script/master'+
    '/extras/coffee-script.js|coffee-script/coffee-script'
    '/ext/coffee-script/coffee-script.js', loaded)
