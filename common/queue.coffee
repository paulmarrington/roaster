# Copyright (C) 2013 paul@marrington.net, see GPL for license

class Queue extends require('events').EventEmitter
  @instance: (owner..., action) ->
    queue = new Queue()
    queue.owner = owner[0] ? queue
    queue.owner.q = queue
    action.apply(queue.owner)
    return queue
    
  constructor: ->
    @reset()
    @maximum_time_seconds = 15
    Object.defineProperty @, "error", set: (value) =>
      @emit('error', value) if value
  # add additional steps
  queue: (notes..., step) ->
    return if @aborted
    step.notes = notes
    @steps.push step; @nexted++
    @next() if @idling
  # move to next item in queue with @next()
  next: (cb) ->
    return (=> cb.apply(@, arguments); @next()) if cb
    return --@defer if @defer
    return if @nexted isnt @steps.length
    clearTimeout @step_timer
    return if @idling = (@steps.length is 0)
    @nexted--; @start_timer fn = @steps.shift()
    @tracer?("Queue step: #{fn.toString()}")
    @lock = true; fn.apply(@owner); @lock = false
  # Do not do any further steps
  abort: -> @reset(@aborted = true)
  # drop all outstanding steps
  reset: ->
    clearTimeout @step_timer
    @steps = []; @nexted = 0
    @idling = true
  # Given one method and data list, call sequentially for each
  list: (ls..., processor) =>
    ls = ls[0] if ls.length is 1 and ls[0] instanceof Array
    do process_next = =>
      return @next() if not list.length
      processor(ls.shift(), process_next)
  # Given a list of closures, process then sequentially
  sequence: (ls...) ->
    @list ls..., (item, next) -> item(next)
  # callbacks that are never called are invisible without this
  start_timer: (fn = @last_timed_function) ->
    #fn.notes = new Error('').stack
    @context = @last_timed_function = fn
    @restart_timer()
  # stop timer for long operations
  restart_timer: (seconds = @maximum_time_seconds) ->
    clearTimeout @step_timer
    @step_timer = setTimeout (=>
      err = new Error """\n
        Queue step over #{seconds} seconds
        #{@context.name ? ''}
        #{@references()}
        #{@context.notes ? ''}
        #{@context.toString()}"""
      @tracer?(err.stack)
      @emit 'error', err
      ), seconds * 1000
  # Display each step before running it or notes on timeout
  trace: (what = true) ->
    if what instanceof Function
      return @tracer?(what) if @tracer # show immediately
      # add reference data to be displayed on timeout
      return @reference_list.push note_generator
    return @tracer = null if not what
    @tracer = (args...) ->
      console.error @references()
      console.error args...
  reference_list: []
  references: ->
    [todo, @reference_list] = [@reference_list, []]
    return (note().toString() for note in todo).join('\n')
  # convert methods with a callback to queue items
  @modex: (func) ->
    return (args...) -> # wrap function to add modality
      # already in queue - just do it now
      return func.apply(@, args) if @lock
      self = @__queue__ ? @
      if (end = args.length - 1) >= 0 and
      (next = args[end]) instanceof Function
        # last argument is a callback
        @nargs = null
        args[end] = (nargs...) ->
          self.nargs = nargs
          self.tracer?('modex-orig-cb', nargs, self.next)
          self.next()
        # call with replacement callback to @next()
        self.queue func, ->
          @tracer?('modex', args, func)
          func.apply(self, args)
        # fire off provided callback
        self.queue func, ->
          @tracer?('modex-next', next, @nargs)
          next.apply(self, @nargs)
      else # function does not provide callback
        @tracer?('modex-direct', func, args)
        self.queue func, -> func.apply(self, args); self.next()
      
  @mixin: (packages) ->
    for name, entry of packages then do =>
      if entry instanceof Function
        return Queue::[name] = Queue.modex(entry)
      # so @files.rm will set rm context to steps/queue
      mixin = {}
      Object.defineProperty Queue::, name, get: ->
        mixin.__queue__ = @
        return mixin
      for own key, value of entry
        if value instanceof Function
          mixin[key] = Queue.modex(value)

module.exports = Queue
