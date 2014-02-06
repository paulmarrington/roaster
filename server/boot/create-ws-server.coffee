# Copyright (C) 2013 paul@marrington.net, see GPL for license
stream = require 'stream'; npm = require 'npm'
url = require 'url'; files = require 'files'

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
module.exports = (environment, next) ->
  options = server: environment.http_server
  
  npm 'ws', (error, ws) ->
    (new ws.Server(options)).on 'connection', (wss) ->
      wss.url = url.parse wss.upgradeReq.url, true
      wss.streams = ->
        wss.from_browser = new FromBrowserStream(wss)
        wss.to_browser = new ToBrowserStream(wss)
      files.find wss.url.pathname, (filename) ->
        filename ?= wss.url.pathname
        action = require filename
        action(wss)
    next()
