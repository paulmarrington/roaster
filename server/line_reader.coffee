# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
fs = require 'fs'; stream = require('stream')

# Read lines from a stream -
# with the same stream pattern of pause and resume.
class LineReader extends stream.Stream
  constructor: (@reader) ->
    @paused = false
    @lines = []
    buffer = ''
    @reader.setEncoding 'utf8'

    @reader.on 'data', (data) =>
      @lines = @lines.concat (buffer + data).split(/\r?\n/)
      buffer = @lines.pop()
      @emitLines()

    @reader.on 'end', =>
      @emit('data', buffer) if buffer.length
      @emit('end')

    @reader.on 'close', => @emit 'close'

  pause: -> @paused = true; @reader.pause()
  resume: -> @paused = false; @emitLines(); @reader.resume()
  destroy: -> @reader.destroy()
  emitLines: ->
    while @lines.length and not @paused
      @emit('data', @lines.shift())

module.exports = (reader) -> new LineReader(reader)
module.exports.for_file = (name, action_per_line) ->
  @reader = new LineReader(fs.createReadStream(name))
  @reader.on 'data', action_per_line
  @reader.on 'end', => @reader.destroy()
  return @reader
module.exports.for_text = (text) -> lines = text.split(/\r?\n/)
