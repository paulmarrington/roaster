# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
module.exports = (exchange) ->
  exchange.respond.json(
    start_time: process.environment.since
    debug_mode: process.environment.config is "debug")
