# Copyright (C) 2013 paul@marrington.net, see GPL for license

module.exports = (exchange, on_completion) ->
  exchange.request.filename = exchange.request.filename.
    replace(/\.library\./, '.').
    replace(/\.library$/, '')
  exchange.is_library = true
  on_completion()