# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'common/step'

class server-step extends step()
  # a common need is to wait for a stream to finish writing
  drain: (stream, data) ->
    if not stream.write data
      then stream.once 'drain', @ else @! # synchronous

  # similarly when we pipe we need to wait for it to complate
  pipe: (input, output) ->
    input.pipe(output, end: false);
    input.on 'end', @

module.exports = server-step
