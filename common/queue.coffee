# Copyright (C) 2013 paul@marrington.net, see GPL for license
# unashamedly cribbed from http://github.com/creationix/step
# in turn inspired by http://github.com/willconant/flow-js

class Queue
  constructor: () ->
    @steps = []
    @maximum_time_ms = 10000
    @total_steps = 0
    @results = []; @lock = false

  # add additional steps
  queue: (step, info = '') ->
    @total_steps++
    return if @aborted
    step.info = info
    @steps.push step
    @next() if @idling
    
  next: ->
    clearTimeout @step_timer
    return if @idling = (@steps.length is 0)
    @start_timer fn = @steps.shift()

    @lock = true
    if @tracing then console.log """
      Queue step #{@total_steps}:
      #{fn.toString()}
      Info: #{info.toString()}"""
    fn.call @, []
    @lock = false
  # see if there is more to done
  empty: -> return not @steps.length
  # @call -> actions - call with queue as this
  # so you can use @next, etc
  call: (func) => func.apply(@, arguments)
  # Do not do any further steps
  abort: =>
    clearTimeout @step_timer
    @aborted = true
    @steps = []
  # Given a list of closures, process then sequentially
  sequence: (ls...) =>
    ls = ls[0] if ls.length is 1 and ls[0] instanceof Array
    do process_next = =>
      return @next() if not ls.length
      ls.shift()(process_next)
  # Given one method and data list, call sequentially for each
  list: (ls..., processor) =>
    ls = ls[0] if ls.length is 1 and ls[0] instanceof Array
    do process_next = =>
      return @next() if not list.length
      processor ls.shift(), process_next
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
  # stop timer for long operations
  stop_timer: => clearTimeout @step_timer
  # Display each step before running it
  trace: (tracing = true) -> @tracing = tracing

  # convert methods with a callback to queue items
  @modex: (func) ->
    if func instanceof Function
      return (args...) -> # wrap function to add modality
        # already in queue - just do it now
        return func.apply(@, args) if @lock
        self = @__queue__ ? @
        if (end = args.length - 1) >= 0 and
        (next = args[end]) instanceof Function
          # last argument is a callback
          @nargs = null
          args[end] = (@nargs...) -> self.next()
          # call with replacement callback to @next()
          self.queue ->
            console.log 'modex', args, func if @tracing
            func.apply(self, args)
          # fire off provided callback
          self.queue ->
            console.log 'modex-next', next, @nargs if @tracing
            next.apply(self, @nargs)
        else # function does not provide callback
          # func itself will decide on async or sync
          console.log 'modex-direct', func, args if @tracing
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

module.exports = Queue