# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
# unashamedly cribbed from http://github.com/creationix/step
# in turn inspired by http://github.com/willconant/flow-js

events = require('events')

class Steps extends events.EventEmitter
  constructor: (@steps) ->
    @pending = 0
    @results = []; @lock = false
    @maximum_time_ms = process.environment.steps_timeout_ms
    @total_steps = @steps.length
    # referencing @next will set step to be asynchronous
    Object.defineProperty @, "next", get: =>
      @asynchronous()
      return @_next
    # setting an error property will emit an error event
    Object.defineProperty @, "error", set: (value) =>
      @emit('error', value) if value
    # by default an error will log rather than throw an exception
    @on 'error', @log_error
    # lastly we start of the running of steps.
    @_next()

  next_if_unreferenced: -> @_next() if not @next_referenced

  _next: (callback) =>
    # if passed a callback closure, return it with an @next() call if needed
    if callback
      step_number = @steps.length
      return =>
        callback.apply(@, arguments)
        # make sure next hasn't been called explicitly
        @_next() if step_number = @steps.length
    # normal next will run the next function in the call argument list.
    clearTimeout @step_timer
    @next_referenced = false
    @pending = @contains_parallels = 0
    return if @steps.length is 0

    @start_timer fn = @steps.shift() # Get the next step to execute

    try
      @lock = true;
      if fn instanceof Array
        @parallel fn
      else # normally synchronous, but checks @next access to be sure
        fn.call(@, @_next)
        @next_if_unreferenced()
    catch exception
      exception.step = @total_steps - @steps.length
      # exception.calling = fn.toString()
      exception.trace = exception.stack if exception.stack
      @emit 'error', exception
      @next()

    @lock = false
    # ok, all entries were synchronous so parallel did not get to
    # process them because the lock above was on
    @next() if @pending is 0 and @contains_parallels

  abort: (error) => @steps = []; @error error

  asynchronous: => @next_referenced = true

  # Add a special callback generator `this.parallel()` that groups stuff.
  parallel: =>
    @contains_parallels = true
    if arguments.length # use for @parallel(-> a, -> b, ...)
      return fn.apply(@parallel()) for fn in arguments
    else
      @pending++
      @asynchronous()
      return =>
        @pending--
        # When all parallel branches done, call the callback
        @next() if not @lock and @pending is 0

  start_timer: (fn) =>
    step = @total_steps - @steps.length
    @step_timer = setTimeout (=>
      err = """\n
        Step did not complete in #{@maximum_time_ms} ms (@next not called)
        (change @maximum_time_ms if process needs more time)
        Function being called in step #{step} was:

        #{fn.notes ? ''}

        #{fn.toString()}"""
      # console.log err
      @emit 'error', err
      @next()
      ), @maximum_time_ms

  log_error: (error) =>
      console.log """
        Error: #{error}
            Step: #{error.step ? ''}
            Trace: #{error.trace ? ''}"""
module.exports = -> return Steps
