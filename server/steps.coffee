# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
Steps = require 'common/steps'; path = require 'path'; npm = require 'npm'
wait_for = require('common/wait_for'); loading = {}

# when draining a stream we need to know when to do more
Steps::drain = (stream, data) ->
  if not stream.write data
    stream.once 'drain', @next
  else # synchronous
    @next()

# similarly when we pipe we need to wait for it to complete. This version will
# take any number of pipes - inner ones mus both read and write.
Steps::pipe = (input, pipes...) ->
  @asynchronous()
  next_called = false
  next = (@error) =>
    return if next_called
    next_called = true
    @next()
  last_target = pipes.slice(-1)[0]
  last_target.on 'finish', next
  last_target.on 'close', next
  input.on 'error', @next (@error) ->
  for pipe in pipes
    pipe.on 'error', @next (@error) ->
    input = input.pipe pipe

# another pipe implementation - to sequentially pipe all inputs to output
Steps::cat = (inputs..., output) ->
  @asynchronous()
  next_called = false
  next = (@error) =>
    return if next_called
    next_called = true
    @next()
  output.on 'finish', next
  output.on 'close', next
  do piper = =>
    return output.end() if not inputs.length
    input = inputs.shift()
    input.on 'error', (err) => console.log(err.stack); @error = err; output.end()
    input.on 'end', piper
    input.pipe output, end:false

# possibly asynchronous requires
Steps::requires = (modules...) ->
  for name in modules
    key = path.basename(name).replace /\W/g, '_'
    try @[key] = require(name) catch error
      npm.check_for_missing_requirement name, error
      if not loading[name]
        load = (name, key, ready) =>
          npm.load name, (error, module) =>
            if error then @errors = error else @[key] = module
            ready()
        loading[name] = wait_for((next) -> load(name, key, next))
      parallel = @parallel()
      loading[name] =>
        @[key] ?= require(name)
        parallel()

# set default timeout based on environment (debug or not)
#Steps::steps_timeout_ms = process.environment.steps_timeout_ms

module.exports = (steps...) -> new Steps(steps)