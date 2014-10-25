# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
os = require 'os'; querystring = require 'querystring'

# some scripts are platform dependent - so provide a check
# os.expecting('windows|unix|darwin|linux')
os.expecting = (system) ->
  runningOn = os.type().toLowerCase()
  system = system.toLowerCase()
  system = 'darwin' if system is 'os x'
  return system is runningOn or
         system is 'unix' and runningOn isnt 'windows'

# unix systems don't have an extension for executables
os.executable_extension =
  if os.expecting('windows') then '.exe' else ''
    
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
    
os.hosts = ->
  hosts = []
  for dev,cons of os.networkInterfaces() then for host in cons
    if not host.internal and host.family is 'IPv4'
      hosts.push host.address
  hosts = ['127.0.0.1'] if not hosts.length
  return hosts

module.exports = os
