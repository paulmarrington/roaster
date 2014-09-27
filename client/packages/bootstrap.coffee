# Copyright (C) 2014 paul@marrington.net, see /GPL for license

module.exports = (loaded) ->
  require.dependency(
    dtree: "https://github.com/twbs/bootstrap/archive/master.zip"+
      "|bootstrap"
    "/ext/bootstrap/dist/js/bootstrap.js"
    "/ext/bootstrap/dist/css/bootstrap.css"
    loaded
  )
