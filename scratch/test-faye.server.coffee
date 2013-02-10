faye = require('faye')('http://localhost:9009/faye')
console.log "Server: subscribe to '/channel/on-server'"
faye.subscribe '/channel/on-server', (message) -> console.log message.text
publish = ->
  console.log "Server: publish to '/channel/on-client'"
  faye.publish '/channel/on-client', text: 'from server to client'
  console.log "Server: publish to '/channel/on-server'"
  faye.publish '/channel/on-server', text: 'from server to server'

module.exports = (exchange) ->
  setTimeout publish, 1000
  exchange.respond.setMimeType 'js'
  exchange.response.end("console.log('test-faye.server.coffee ran')")
