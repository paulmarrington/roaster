# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
fs = require 'fs'; dirs = require 'dirs'

module.exports = (exchange) ->
  fs.stat dirs.base(), (err, stats) ->
    exchange.respond.json(process.environment.configuration)
