# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
os = require 'os'; querystring = require 'querystring';

# some scripts are platform dependent - so provide a check
os.expecting = (system) -> # os.expecting('windows|unix|darwin|linux')
  runningOn = os.type().toLowerCase()
  system = system.toLowerCase()
  return system is runningOn or system is 'unix' and runningOn isnt 'windows'

# process a command line of the form 'a=b c=d' into a map - with defaults
os.command_line = (defaults) ->
  args = querystring.parse(process.argv[3..].join('&'))
  args[item] ?= defaults[item] for item of defaults
  return args

# Throw an exception if the error arg on a callback is filled. Use it in
# place of any standardised callback: myfunc args, throw_error callback
os.throwError = (next) ->
  return (error, args...) ->
    throw error if error
    next(args...)

module.exports = os
