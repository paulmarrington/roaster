# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
child_process = require 'child_process'

class Processes # proc = require('proc')() # sets default streaming and options
  constructor: (@program) ->
    @options =
      cwd: process.cwd()
      env: process.env
      stdio: ['ignore', process.stdout, process.stderr]

  # Fork off a separate node process to run the V8 scripts in a separate space
  node: (@args..., @next) -> @_exec(child_process.fork)

  # Spawn off a separate OS process - next(code) provides return code
  spawn: (@args..., @next) -> @_exec(child_process.spawn)

  # Spawn off a job and keep restarting it if it dies
  restart: (@args...) ->
    return @proc.kill() if @proc
    @_restart()

  _restart: ->
    @next = ->
    @start_time = new Date().getTime()
    @_exec(child_process.spawn)
    @proc.on 'exit', (code, signal) =>
      @proc = null
      # restarting fails if service ran less than 5 seconds
      if signal or (new Date().getTime() - @start_time) > 5000
        @_restart()
    return @proc

  # kill this process if it is currently running
  kill: (signal = 'SIGTERM') -> @proc?.kill()

  # Event listener - returns @ for chaining
  on: (args...) ->
    @proc?.on(args...)
    return @

  # private DRY helper
  _exec: (action) ->
    @proc = action @program, @args, @options
    @proc.on 'exit', (@code, @signal) =>
      return @next(new Error("return code #{@code}", @program)) if @code
      return @next(new Error(@signal, @program)) if @signal
      return @next(null)
    return @proc

module.exports = (program) -> new Processes program
