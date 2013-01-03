# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
template = require('server/http/ext/coffee').template

# script is to be run on the server, load using require
module.exports = (exchange) ->
  template exchange, (filename) -> require(filename)(exchange)
