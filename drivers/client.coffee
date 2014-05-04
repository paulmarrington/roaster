# Copyright (C) 2013 paul@marrington.net, see /GPL for license
driver = require 'http/driver'

module.exports = (exchange, on_completion) ->
  file_name = exchange.request.filename
  file_name = file_name.
    replace(/\.client\./, '.').
    replace(/\.client$/, '')
  exchange.respond.static_file(file_name)
  driver.use_template exchange,
    "templates/client.js", on_completion
