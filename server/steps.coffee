# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
Steps = require 'common/steps'; path = require 'path'; npm = require 'npm'

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
      npm.check_for_missing_requirement name, error
      ready = @parallel()
      npm.load name, (error, module) ->
        if error then @errors.push(error) else @[key] = module
        ready()

# set default timeout based on environment (debug or not)
#Steps::steps_timeout_ms = process.environment.steps_timeout_ms

module.exports = (steps...) -> new Steps(steps)