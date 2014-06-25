# Copyright (C) 2012 paul@marrington.net, see GPL for license
fs = require 'fs'; path = require 'path'; dirs = require 'dirs'

module.exports = (exchange) ->
  file = dirs.base exchange.request.url.query.filename
  exchange.respond.static_file(file).send_static()
