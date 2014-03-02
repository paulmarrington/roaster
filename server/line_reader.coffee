# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
fs = require 'fs'; stream = require 'stream'

# Read lines from a stream -
# with the same stream pattern of pause and resume.
class LineReader extends stream.Transform
  constructor: (reader) ->
    super objectMode: true
    @buffer = ''
    reader.setEncoding 'utf8'
    reader.on 'error', (err) -> @emit 'error', err
    reader.pipe @
    
  _transform: (chunk, encoding, done) ->
    data = chunk.toString()
    lines = (@buffer + data).split(/\r?\n/)
    @buffer = lines.pop()
    @push line for line in lines
    done()
    
  _flush: (done) ->
    @push @buffer if @buffer?.length
    done()

module.exports = line_reader = (reader, action_per_line) ->
  reader = new LineReader(reader)
  reader.on 'readable', ->
    action_per_line(line) while line = reader.read()
  reader.on 'error', -> action_per_line(null)
  reader.on 'end', -> action_per_line(null)
  return reader

module.exports.for_file = (name, action_per_line) ->
  line_reader fs.createReadStream(name), action_per_line

module.exports.LineReader = LineReader
