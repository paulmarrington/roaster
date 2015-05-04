# Copyright (C) 2014 paul@marrington.net, see /GPL license

module.exports = class Restful
  constructor: (@service) ->
  
  read: (read) -> @converse 'GET', null, read
  
  write: (data, written) -> @converse 'POST', data, written
  
  update: (data, written) -> @converse 'PUT', data, written
  
  delete (done) -> @converse 'DELETE', null, donea
  
  head: (received) -> @converse 'HEAD', null, (err, data) =>
    return received err if err
    received null, @meta
    
  meta: ->
    metadata = {}
    for line in @rq.getAllResponseHeaders().split('\r\n')
      parts = line.split(': ')
      key = parts.shift()
      metadata[key] = parts.join(': ')
      if lm = metadata["Last-Modified"]
        metadata["Last-Modified"] = Date.parse(lm)
    return metadata
  
  converse: (action, data, respond) ->
    @rq = new XMLHttpRequest()
    @rq.addEventListener "error", => respond "Network Error"
    @rq.addEventListener "abort", => respond "Abort"
    @rq.addEventListener "load",  =>
      return respond("Error: #{@rq.statusText}") if @rq.status isnt 200
      respond null, @rq.responseText
    @rq.open action, @service, true
    @rq.send data