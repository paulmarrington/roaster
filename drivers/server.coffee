# Copyright (C) 2013 paul@marrington.net, see GPL for license
driver = require 'http/driver'

module.exports = (exchange, on_completion) ->
  driver.use_template exchange,
    "templates/server.js", on_completion