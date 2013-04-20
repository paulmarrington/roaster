# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

# curl http://localhost:9009/server/http/terminate?exit_code=1&key=yestermorrow
# add &signal=SIGKILL if you don't want the server to restart
module.exports = (exchange) ->
  exchange.respond.script ''
  if exchange.environment.config is 'production' or
    exchange.request.url.query.key isnt 'yestermorrow'
      return

  console.log "Terminate called for roaster:#{exchange.environment.port}"
  if exchange.request.url.query.signal
    process.kill process.pid, exchange.request.url.query.signal
  else
    process.exit exchange.request.url.query.exit_code ? 0
