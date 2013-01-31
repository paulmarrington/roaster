# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'http/driver'; require! 'file-system'; require! 'step'

# called by depends.coffee from the client. It is expecting a script that
# compiles to java-script. It wraps the resultint code in a function as
# expected by the server before sending it back using the original reply
# mechanism
module.exports = (exchange) ->
  wrap = ["#{exchange.request.url.query.global_var}=function(module){", ';}']
  extra = wrap.0.length + wrap.1.length
  exchange.request.filename .= replace '.depends', ''

  writeHead = exchange.response.writeHead
  bytes = 0
  exchange.response.writeHead = ->
    if bytes := exchange.response.get-header 'content-length'
      exchange.response.set-header 'content-length', bytes + extra
    writeHead.call exchange.response, &
    exchange.response.write wrap.0 if bytes

  end = exchange.response.end
  exchange.response.end = ->
    exchange.response.write ... if &.length isnt 0
    exchange.response.write wrap.1 if bytes
    end.call exchange.response
