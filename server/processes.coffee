# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
child_process = require 'child_process'; fs = require 'fs'
dirs = require 'dirs'

class Processes
  constructor: (@program) ->
    @debug_flag = ''
    @options =
      cwd: process.cwd()
      env: process.env
      stdio: 'pipe'

  # Fork off a separate node process to run the V8
  # scripts in a separate space
  node: (@args..., @next) ->
    @node_setup()
    @_exec(child_process.fork)
    return @

  node_setup: ->
    @args = [@program, @args...]
    @args.unshift 'boot/run' if @program isnt 'server'
    @program = dirs.node('boot/load.js')

  # restart runs a node job and restarts it if and when it
  # dies it can also be used to restart an existing process
  restart: (@args...) ->
    return @proc.kill() if @proc
    @node_setup()
    @_respawn(child_process.fork, Infinity)

  # Spawn off a separate OS process -
  # next(code) provides return code
  spawn: (@args..., @next) ->
    @_exec(child_process.spawn)
    return @

  debug: (break_on_start = false) ->
    @debug_flag = if break_on_start then \
    '--debug-brk' else '--debug'

  # exec runs the provided command in a shell
  # (next(error, stdout, stderr))
  exec: (next) ->
    child_process.exec @program, @options, next
    return @

  # half-way between a spawn and exec - it fires up a shell,
  # but pipes I/o
  cmd: (@args..., @next) ->
    @program = process.env.SHELL ? process.env.ComSpec
    is_unix = require('system').expecting 'unix'
    if @args.length
      c_switch = if is_unix then '-c' else '/c'
      @args = [c_switch, @args...]
    @_exec(child_process.spawn)
    return @

  # Spawn off a job and keep restarting it if it dies
  # it can also be used to respawn an existing process
  respawn: (@args...) ->
    return @proc.kill() if @proc
    @_respawn(child_process.spawn, 1000)

  _respawn: (action, minimum_run_time) ->
    @next = ->
    @start_time = new Date().getTime()
    @_exec(action)
    @proc.on 'exit', (code, signal) =>
      @proc = null
      return if signal is 'SIGKILL'
      # restarting fails if service ran less than 5 seconds
      run_time = new Date().getTime() - @start_time
      if signal or run_time > minimum_run_time
        @_respawn(action, minimum_run_time)
    return @proc

  # kill this process if it is currently running
  kill: (signal = 'SIGTERM') ->
    @proc?.kill(signal)

  # Event listener - returns @ for chaining
  on: (args...) ->
    @proc?.on(args...)
    return @
    
  send: (line) -> @proc.stdin.write line+'\n'
  send_file: (name, extra..., next) ->
    input = fs.createReadStream(name)
    input.on 'end', =>
      @send(extra.join('\n')+'\n')
      next()
    input.pipe @proc.stdin, end: false

  # private DRY helper
  _exec: (action) ->
    if @args.length is 1 and typeof @args[0] is 'string'
      @args = @args[0]?.split ' '
    @proc = action @program, @args, @options
    @proc.stdout?.pipe process.stdout
    @proc.stderr?.pipe process.stderr
    @proc.on 'exit', (@code, @signal) =>
      if @code
        return @next(new Error("return code #{@code}", @args))
      return @next(new Error(@signal, @args)) if @signal
      return @next(null)
    return @proc

  decode_query: (query) ->
    decoded = []
    for key, value of query
      decoded.push if value then "#{key}=#{value}" else key
    return decoded

module.exports = (program) -> new Processes program
