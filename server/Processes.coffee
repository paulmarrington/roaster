# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
child = require 'child_process'
    
class Processes # proc = require('proc')() # sets default streaming and options
  constructor: () ->
    @options =
      cwd: process.cwd()
      env: process.env
      stdio: ['ignore', process.stdout, process.stderr]
      
  # Fork off a separate node process to run the V8 scripts in a separate space
  fork: (@program, @args..., @next) -> @_exec(child.fork)
  
  # Spawn off a separate OS process - next(code) provides return code
  spawn: (@program, args..., @next) -> @_exec(child.spawn)

  _exec: (action) ->
    proc = action @program, @args, @options
    proc.on 'exit', (@code, @signal) =>
      return @next(new Error("return code #{@code}", @program)) if @code
      return @next(new Error(@signal, @program)) if @signal
      return @next(null)

module.exports = -> new Processes()
