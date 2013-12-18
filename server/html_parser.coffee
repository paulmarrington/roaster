# Copyright (C) 2013 paul@marrington.net, see GPL for license
EventEmitter = require('events').EventEmitter
fs = require 'fs'; npm = require 'npm'

module.exports = (ready) ->
  parser = new EventEmitter
  npm 'htmlparser2', (error, htmlparser2) ->
    parser.stream = new @htmlparser2.Parser(
      onopentag: (name, attributes) ->
        parser.emit('open', name, attributes)
      ontext: (text) -> parser.emit('text', text)
      onclosetag: (name) -> parser.emit('close', name)
      onend: -> parser.emit('end')
      onreset: -> parser.emit('reset')
      oncdatastart: -> parser.emit('cdata-start')
      oncdataend: -> parser.emit('cdata-end')
      oncomment: (text) -> parser.emit('comment', text)
      oncommentend: -> parser.emit('comment-end')
      onerror: (error) -> parser.emit('error', error)
      )
    parser.file = (name) ->
      reader = fs.createReadStream(name)
      reader.on 'data', (data) -> parser.stream.write data
      reader.on 'end', (data) ->
        parser.stream.end data
        parser.emit 'end'

    ready parser
  return parser
