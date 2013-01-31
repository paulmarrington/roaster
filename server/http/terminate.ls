# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# curl http://localhost:9009/server/http/terminate?exit_code = 1
module.exports = (exchange) ->
  return if exchange.request.url.query.key isnt 'yestermorrow'
  return if exchange.environment.config is 'production'

  process.exit exchange.request.url.query.exit_code ? 0
