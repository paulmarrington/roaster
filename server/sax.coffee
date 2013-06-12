# Copyright (C) 2013 paul@marrington.net, see GPL for license
Stream = require('stream').Stream; fs = require 'fs'

specials = {'script', 'style', 'textarea'}

class Sax extends Stream 
  constructor: ->
    @writable = true
    @partial = ''
    @in_special = null

  end: (data) ->
    @write(data)
    @emit('text', @partial) if @partial.length
    @emit 'finish'
    
  write: (data) ->
    return true if not data
    data = @partial + data
    start = 0
    while (tag_start = data.indexOf('<', start)) != -1
      if not @in_special
        @emit 'text', data[start..tag_start - 1] if start isnt tag_start
        start = tag_start + 1
        break if (tag_end = data.indexOf('>', tag_start)) is -1
        event = 'opening_tag'
        if (is_close = data[start]) is '/' then start++; event = 'closing_tag'
        end -= 1 if data[end = tag_end - 1] is '/'
        # known weakness - spaces in quoted values will be separate parts
        parts = data[start..end].split /\s+/g
        if specials[tag = parts[0].toLowerCase()]
          @in_special = new RegExp "<\s*/\s*#{tag}\s*>"
        @emit event, parts...
        start = tag_end + 1
      else if (tag_start = data.search(@in_special)) is -1
        @emit 'text', data[start..] if start < data.length
        start = data.length
        break
      else # found end of special
        @in_special = null
        @emit 'text', data[start..tag_start - 1]
        start = data.indexOf('>', tag_start) + 1
        @emit 'closing_tag', data[tag_start + 2..start - 2]
    @partial = data[start..]
    return true

module.exports = Sax
