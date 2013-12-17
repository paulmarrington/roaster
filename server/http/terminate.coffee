# Copyright (C) 2013 paul@marrington.net, see /GPL for license

# curl http://localhost:9009/server/http/terminate?
# exit_code=1&key=yestermorrow
# add &signal=SIGKILL if you don't want the server to restart
module.exports = (exchange) ->
  exchange.respond.json pid:process.pid
  return if exchange.environment.config isnt 'debug'

  console.log
  "Terminate called for roaster:#{exchange.environment.port}"
  if exchange.request.url.query.signal
    process.kill process.pid, exchange.request.url.query.signal
  else
    process.exit exchange.request.url.query.exit_code ? 0
