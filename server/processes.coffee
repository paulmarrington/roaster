# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
child_process = require 'child_process'

class Processes # proc = require('proc')() # sets default streaming and options
  constructor: (@program) ->
    @options =
      cwd: process.cwd()
      env: process.env
      stdio: ['ignore', process.stdout, process.stderr]

  # Fork off a separate node process to run the V8 scripts in a separate space
  node: (@args..., @next) -> @_exec(child_process.fork); return @

  # Spawn off a separate OS process - next(code) provides return code
  spawn: (@args..., @next) -> @_exec(child_process.spawn); return @

  # exec runs the provided command in a shell (next(error, stdout, stderr))
  exec: (next) -> child_process.exec @program, @options, next; return @

  # half-way between a spawn and exec - it fires up a shell, but pipes I/I
  cmd: (@args..., @next) ->
    @program = process.env.SHELL ? process.env.ComSpec
    is_unix = require('system').expecting 'unix'
    c_switch = if is_unix then '-c' else '/c'
    @args = [c_switch, @args...]
    @_exec(child_process.spawn)
    return @

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
      return if signal is 'SIGKILL'
      # restarting fails if service ran less than 5 seconds
      if signal or (new Date().getTime() - @start_time) > 1000
        @_restart()
    return @proc

  # kill this process if it is currently running
  kill: (signal = 'SIGTERM') ->
    @proc?.kill(signal)

  # Event listener - returns @ for chaining
  on: (args...) ->
    @proc?.on(args...)
    return @

  # private DRY helper
  _exec: (action) ->
    @args = @args[0]?.split ' ' if @args.length is 1
    @proc = action @program, @args, @options
    @proc.on 'exit', (@code, @signal) =>
      return @next(new Error("return code #{@code}", @program)) if @code
      return @next(new Error(@signal, @program)) if @signal
      return @next(null)
    return @proc

module.exports = (program) -> new Processes program
