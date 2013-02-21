# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
Step = require('common/step')()

# when draining a stream we need to know when to do more
Step::drain = (stream, data) ->
    if not stream.write data
      stream.once 'drain', @next
    else # synchronous
      @next()

# similarly when we pipe we need to wait for it to complate
Step::pipe = (input, output) ->
    input.pipe(output, end: false);
    input.on 'end', @next

module.exports = -> new Step(arguments)
