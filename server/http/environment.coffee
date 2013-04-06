# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
module.exports = (exchange) ->
  exchange.respond.json(process.environment.configuration)
