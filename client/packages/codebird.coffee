# Copyright (C) 2014 paul@marrington.net, see /GPL for license
version = "3.2.0"

module.exports = (loaded) ->
  require.dependency(
    dtree: "https://github.com/jublonet/"+
    "codebird-js/archive/develop.zip|codebird"
    "/ext/codebird/codebird.js"
    loaded
  )
