# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
Steps = require('common/steps')(); path = require 'path'
demand = require('demand')

# when draining a stream we need to know when to do more
Steps::drain = (stream, data) ->
  if not stream.write data
    stream.once 'drain', @next
  else # synchronous
    @next()

# similarly when we pipe we need to wait for it to complate
Steps::pipe = (input, output) ->
  input.pipe(output, end: false);
  input.on 'end', @next

# possibly asynchronous requires
Steps::requires = (modules...) ->
  for name in modules
    key = path.basename(name)
    try @[key] = require(name) catch error
      demand.check_for_missing_requirement name, error
      ready = @parallel()
      demand.load name, (error, module) ->
        if error then @errors.push(error) else @[key] = module
        ready()

module.exports = (steps...) -> new Steps(steps)