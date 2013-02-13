# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
Processes = require 'Processes'

 module.exports = (exchange) ->
    proc = Processes()
    # Output will be wiki text as written by stdout and stderr
    exchange.respond.set-mime-type 'txt'
    url = exchange.request.url
    args = [url.pathname, url.query, url.hash]
    proc.options.stdio = ['ignore', exchange.response, exchange.response]
    proc.program = program
    proc.spawn ...@args, (error) ~>
      @exchange.response.end()
      throw error if error
