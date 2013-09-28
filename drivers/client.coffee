# Copyright (C) 2013 paul@marrington.net, see /GPL for license
steps = require 'steps', driver = require 'http/driver'

module.exports = (exchange, on_completion) ->
  exchange.respond.static_file()
  driver.use_template exchange,
    "templates/client.js", on_completion
