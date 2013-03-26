# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

module.exports = (exchange, on_completion) ->
  exchange.is_library = true
  on_completion()