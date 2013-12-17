# Copyright (C) 2013 paul@marrington.net, see GPL for license
stream = require 'stream'; requires = require 'requires'

# Websocket wrapper includes a duplex stream (for pipes mainly)
class FromBrowserStream extends stream.Readable
  constructor: (@ws) ->
    super()
    @ws.on 'message', (data, flags) =>
      @ws.pause() if not @push(data ? '')
    @ws.on 'error', (error) -> @emit 'error', error
    @ws.on 'close', (code, message) => push(null)
  _read: (size) => @ws.resume()

class ToBrowserStream extends stream.Writable
  constructor: (@ws) ->
    super()
    @ws.on 'error', (error) => @emit 'error', error
    @ws.on 'close', (code, message) => @end()
  _write: (chunk, encoding, next) => @ws.send(chunk, next)

# calls web service - events message, close, error
module.exports = (environment) ->
  options = server: environment.http_server
  
  requires 'ws', (error, ws) ->
    (new ws.Server(options)).on 'connection', (wss) ->
      wss.from_browser = new FromBrowserStream(wss)
      wss.to_browser = new ToBrowserStream(wss)
      require(wss.upgradeReq.url[1..-1].split('?')[0])(wss)