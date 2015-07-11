# Copyright (C) 2013 paul@marrington.net, see GPL for license
Writable = require('stream').Writable
fs = require 'fs'; require 'common/strings'

specials = {'script', 'style', 'textarea'}

class Sax extends Writable
  constructor: ->
    super()
    @partial = ''
    @in_special = null
    @on 'finish', ->
      @emit('text', @partial) if @partial.length
    
  _write: (data, encoding, next) ->
    data = @partial + data.toString()
    start = 0
    done = =>
      @partial = data[start..]
      next()
    do get_next_tag = =>
      if (tag_start = data.indexOf('<', start)) is -1
        return done()
      if not @in_special
        if start isnt tag_start
          @emit 'text', data[start..tag_start - 1]
        start = tag_start + 1
        if (tag_end = data.indexOf('>', tag_start)) is -1
          return done()
        event = 'opening_tag'
        if (is_close = data[start]) is '/'
          start++; event = 'closing_tag'
        end -= 1 if data[end = tag_end - 1] is '/'
        [all,tag,guts] = /^(\w+)\s*(.*)$/.exec data[start..end]
        attributes = {}
        guts.replace /(\S+)(?:=['"](.*?)['"])/g, (b, k, v) =>
          attributes[k.toLowerCase()] = v
        @in_special = new RegExp "<\s*/\s*#{tag}\s*>" if specials[tag]
        start = tag_end + 1
        @emit event, tag, attributes, get_next_tag
      else if (tag_start = data.regex_index_of(
        @in_special, tag_start)) isnt -1
        @in_special = null
        @emit 'text', data[start..tag_start - 1]
        start = data.indexOf('>', tag_start) + 1
        @emit 'closing_tag', data[tag_start + 2..start - 2], {}, get_next_tag
      else # end of chunk
        @emit 'text', data[start..] if start < data.length
        start = data.length

module.exports = Sax
