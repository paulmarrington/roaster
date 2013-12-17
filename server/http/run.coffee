# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
Processes = require 'processes'

module.exports = (exchange) ->
  proc = processes()
  # Output will be wiki text as written by stdout and stderr
  exchange.respond.set_mime_type 'txt'
  url = exchange.request.url
  args = [url.pathname, url.query, url.hash]
  proc.options.stdio =
    ['ignore', exchange.response, exchange.response]
  proc.program = program
  proc.spawn @args..., (error) =>
    @exchange.response.end()
    throw error if error
