# Copyright (C) 2013 paul@marrington.net, see GPL for license
stream = require 'stream'
  
class StringToStream extends stream.Readable
  constructor: (@string) ->
    super()
    @done = false
  _read: (size) ->
    return @push(null) if @done
    @push @string
    @done = true

String::to_stream = -> new StringToStream(@.toString())

streams = module.exports =
  # similarly when we pipe we need to wait for it to complete.
  # This version will take any number of pipes - inner ones
  # must both read and write.
  pipe: (input, pipes..., next) ->
    next_called = false
    nextq = (error) =>
      return if next_called
      next_called = true
      next(error)
    last_target = pipes.slice(-1)[0]
    last_target.on 'finish', nextq
    last_target.on 'close', nextq
    input.on 'error', nextq
    for pipe in pipes
      return if next_called
      pipe.on 'error', nextq
      input = input.pipe pipe
  
  # another pipe implementation -
  # to sequentially pipe all inputs to output
  cat: (inputs..., output, next) ->
    next_called = false
    nextq = (error) =>
      return if next_called
      next_called = true
      next(error)
    output.on 'finish', nextq
    output.on 'close', nextq
    do piper = =>
      return output.end() if not inputs.length
      input = inputs.shift()
      input.on 'error', (err) =>
        console.log(err.stack); nextq(err); output.end()
      input.on 'end', piper
      input.pipe output, end:false
