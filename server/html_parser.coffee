# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
steps = require 'steps'; EventEmitter = require('events').EventEmitter
fs = require 'fs'

module.exports = (ready) ->
  parser = new EventEmitter

  load_Libraries = -> @require 'htmlparser2'

  convert_parser_to_event_emitter = ->
    parser.stream = new @html_parser2.Parser(
      onopentag: (name, attributes) -> parser.emit('open', name, attributes)
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

  set_file_parser = ->
    parser.file = (name) ->
      reader = fs.createReadStream(name)
      reader.on 'data', (data) -> parser.stream.write data
      reader.on 'end', (data) ->
        parser.stream.end data
        parser.emit 'end'

  parser_ready_for_use = -> ready parser

  steps(
    convert_parser_to_event_emitter
    set_file_parser
    parser_ready_for_use
    )
  return parser
