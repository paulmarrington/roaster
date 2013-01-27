# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# This driver is called last - it puts it all together and sends results
module.exports = (exchange) ->
  # if we don't have a domain from drivers, default to servlet
  require('http/drivers/server')(exchange) if not exchange.domain
  # and send a reply based on all the instructions
  exchange.reply exchange.morph
