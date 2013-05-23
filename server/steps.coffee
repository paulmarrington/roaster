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
  pipes.slice(-1)[0].on 'close', @next
  for pipe in pipes
    input = input.pipe pipe

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