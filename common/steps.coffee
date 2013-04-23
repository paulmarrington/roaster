# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
# unashamedly cribbed from http://github.com/creationix/step
# in turn inspired by http://github.com/willconant/flow-js

events = require('events')

class Steps extends events.EventEmitter
  constructor: (@steps) ->
    @pending = 0
    @results = []; @lock = false
    @maximum_time_ms = process?.environment?.steps_timeout_ms ? 60000
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
    # parallel only nexts when all done
    return if @contains_parallels and --@pending and not @lock
    # if passed a callback closure, return it with an @next() call if needed
    if callback
      step_number_for_this_callback = @steps.length
      return =>
        if @tracing then console.log """
          Callback for step #{step_number_for_this_callback}:
          #{callback.toString()}"""
        callback.apply(@, arguments)
        # make sure next hasn't been called explicitly
        @_next() if step_number_for_this_callback is @steps.length
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
        if @tracing then console.log """
          Step #{@steps.length + 1}:
          #{fn.toString()}"""
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
  # @call -> actions - call with steps as this so you can use @next, etc
  skip: => @steps.shift() if @steps.length
  call: (func) => func.apply(@, arguments)
  abort: (error) => @steps = []; @error = error; clearTimeout @step_timer
  long_operation: (seconds = 300) => @maximum_time_ms = seconds * 1000

  asynchronous: => @next_referenced = true

  # Add a special callback generator `this.parallel()` that groups stuff.
  parallel: =>
    @contains_parallels = true
    @asynchronous()
    if arguments.length # use for @parallel(-> a, -> b, ...)
      for fn in arguments
        @pending++
        fn.call(@)
    else # use for fn, args..., @parallel()
      @pending++
      return @next

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
  # Display each step before running it
  trace: (tracing = true) -> @tracing = tracing
module.exports = Steps
