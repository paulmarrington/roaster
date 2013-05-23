# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
os = require 'os'; querystring = require 'querystring';

# some scripts are platform dependent - so provide a check
os.expecting = (system) -> # os.expecting('windows|unix|darwin|linux')
  runningOn = os.type().toLowerCase()
  system = system.toLowerCase()
  system = 'darwin' if system is 'os x'
  return system is runningOn or system is 'unix' and runningOn isnt 'windows'

# process a command line of the form 'a=b c=d' into a map - with defaults
os.command_line = ->
  return querystring.parse(process.argv[3..].join('&'))

os.help = (program, options) ->
  text = [program]
  text.push "#{key}=#{value}" for key, value of options
  console.log "usage: #{text.join(' ')}"

# Throw an exception if the error arg on a callback is filled. Use it in
# place of any standardised callback: myfunc args, throw_error callback
os.throwError = (next) ->
  return (error, args...) ->
    throw error if error
    next(args...)

module.exports = os
