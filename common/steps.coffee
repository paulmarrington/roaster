# Copyright (C) 2013 paul@marrington.net, see GPL for license
# unashamedly cribbed from http://github.com/creationix/step
# in turn inspired by http://github.com/willconant/flow-js

events = require('events')

class Steps extends events.EventEmitter
  constructor: (@steps = []) ->
    @self = @ # first param could be context
    if not (steps?[0] instanceof Function)
      @self = @steps.shift()
    @all_asynchronous = false
    @pending = 0
    @results = []; @lock = false
    @maximum_time_ms =
      process?.environment?.steps_timeout_ms ? 60000
    @total_steps = @steps.length
    # allows us to save reference and use out of context
    @queue = (actions...) => @add(actions...)
    @queue.instance = @instance = @
    # referencing @next will set step to be asynchronous
    Object.defineProperty @, "next", get: =>
      @asynchronous()
      return @_next
    # setting an error property will emit an error event
    Object.defineProperty @, "error", set: (value) =>
      @emit('error', value) if value
    # by default an error will log (not throw an exception)
    # @on 'error', @log_error
    # lastly we start of the running of steps.
    @_next()
    
  _next: (callback) =>
    # parallel only nexts when all done
    return if @contains_parallels and --@pending and not @lock
    # if passed a callback closure, return it with an
    # @next() call if needed
    if callback and callback instanceof Function
      step_number_for_callback = @steps.length
      return =>
        if @tracing then console.log """
          Callback for step #{step_number_for_callback}:
          #{callback.toString()}"""
        callback.apply(@, arguments)
        # make sure next hasn't been called explicitly
        @_next() if step_number_for_callback <= @steps.length
          
    # normal next will run the next function in the
    # call argument list.
    clearTimeout @step_timer
    @next_referenced = @all_asynchronous
    @pending = @contains_parallels = 0
    return @idling = true if @steps.length is 0
    @idling = false
    # Get the next step to execute
    @start_timer fn = @steps.shift()

    try
      @lock = true
      if fn instanceof Array
        @parallel fn
      else # normally sync, but checks @next access to be sure
        if @tracing then console.log """
          Step #{@steps.length + 1}/#{@total_steps}:
          #{fn.toString()}"""
        this_step = @steps.length
        # one parameter is @next
        if fn.length
          @asynchronous()
          param = (=> @next())
        fn.call @, param
        if not @next_referenced and this_step is @steps.length
          @_next()
    catch exception
      exception.step = @total_steps - @steps.length
      # exception.calling = fn.toString()
      @emit 'error', exception
      @_next() if this_step is @steps.length

    @lock = false
    # ok, all entries were synchronous so parallel did not
    # get to process them because the lock above was on
    @next() if @pending is 0 and @contains_parallels
  # add additional steps
  add: (more...) ->
    @total_steps++
    return if @aborted
    @steps.push more...
    @_next() if @idling
  # see if there is more to done
  empty: -> return not @steps.length
  # skip the next step
  skip: => @steps.shift() if @steps.length; @next()
  # @call -> actions - call with steps as this
  # so you can use @next, etc
  call: (func) => func.apply(@, arguments)
  # Do not do any further steps
  abort: (next) =>
    clearTimeout @step_timer
    @aborted = true
    @steps = []
    next?.apply(@)
  # wait longer for async ops to complete (default 5 min)
  long_operation: (seconds = 300) =>
    @maximum_time_ms = seconds * 1000
    @start_timer()
  # if @next is in a function it can't infer asyn
  asynchronous: => @next_referenced = true
  # Given a list of closures, process then sequentially
  sequence: (list...) =>
    if list.length is 1 and list[0] instanceof Array
      list = list[0]
    @asynchronous()
    do process_next = =>
      return @next() if not list.length
      list.shift()(process_next)
  # Given one method and data list, call sequentially for each
  list: (list..., processor) =>
    if list.length is 1 and list[0] instanceof Array
      list = list[0]
    @asynchronous()
    do process_next = =>
      return @next() if not list.length
      try
        processor list.shift(), process_next
      catch exception
        @emit 'error', exception
        process_next()
  # Add a special callback generator `this.parallel()`
  # that groups stuff.
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
  # callbacks that are never called are invisible without this
  start_timer: (fn = @last_timed_function) =>
    @last_timed_function = fn
    clearTimeout @step_timer
    step = @total_steps - @steps.length
    @step_timer = setTimeout (=>
      err = new Error """\n
        Step did not complete in #{@maximum_time_ms} ms
        @next was not called
        (change @maximum_time_ms if process needs more time)
        Function being called in step #{step} was:

        #{fn.notes ? ''}

        #{fn.toString()}"""
      @emit 'error', err
      @next()
      ), @maximum_time_ms
  #
  # log_error: (error) =>
  #   console.log "Error:", error
  #   console.log "Step:", error.step if error.step?.length
  #   console.log "Trace:", error.stack if error.stack?.length

  # Display each step before running it
  trace: (tracing = true) -> @tracing = tracing

  # decide if a call is synchronous or async - for Queue
  @modex: (func) ->
    if func instanceof Function
      return (args...) -> # wrap function to add modality
        # already in queue - just do it now
        return func.apply(@, args) if @lock
        self = @
        self = @__queue__ if self not instanceof Steps
        if (end = args.length - 1) >= 0 and
        (next = args[end]) instanceof Function
          # last argument is a callback
          next_args = null
          args[end] = ->
            next_args = arguments
            if @tracing
              console.log 'modex-last',self.next
            self.next()
          # call with replacement callback to @next()
          self.queue ->
            @asynchronous()
            console.log 'modex', args, func if @tracing
            func.apply(self, args)
          # fire off provided callback
          self.queue ->
            if @tracing
              console.log 'modex-end', next_args, next
            next.apply(self, next_args)
        else # function does not provide callback
          # func itself will decide on async or sync
          console.log 'modex-direct', args, func if @tracing
          self.queue -> func.apply(self, args)
    else # not a function - use as-is
      return func
      
  @mixin: (Queue, packages) ->
    for name, entry of packages then do =>
      if entry instanceof Function
        return Queue[name] = @modex(entry)
      # so @files.rm will set rm context to steps/queue
      mixin = {}
      Object.defineProperty Queue::, name, get: ->
        mixin.__queue__ = @
        return mixin
        
      mixin[key] = @modex(value) for own key, value of entry

module.exports = Steps
