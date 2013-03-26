# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
fs = require 'fs'

module.exports = (exchange) ->
  module_name = exchange.request.url.pathname.replace(/.client.node$/, '')[1..]
  module_path.resolve(module_name)
  if module_path.indexOf('/') is -1
    module_path = fs.node "ext/node_lib/#{module_path}.js"
    fs.exists module_path, (exists) ->

  module = require(module_name)
  exchange.respond.client module
