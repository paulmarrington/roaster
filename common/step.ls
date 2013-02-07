# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
# unashamedly cribbed from http://github.com/creationix/step
# in turn inspired by http://github.com/willconant/flow-js

# @throw_errors = true # throw an exception on an error
# @throw_errors = false # call next with error parameter set
# @() # will move a synchronous function to the next step
step = (...steps) ->

  step_index = counter = pending = 0
  results = []; lock = false

  # Define the main callback that's given as `this` to the steps.
  next = (err, ...args) ->
    counter := pending := error = 0
    if step_index >= steps.length # all done
      throw err if err # no more steps - throw our error
      return  # all done

    fn = steps[step_index++] # Get the next step to execute
    results := []

    try # Run the step in a try/catch block so exceptions don't get out of hand.
      lock := true;
      result = fn.apply(next, arguments)
    catch exception
      throw exception if next.throw_errors
      next exception # Pass any exceptions on through the next callback

    lock := false
    # ok, all entries were synchronous so parallel did not get to
    # process them because the lock above was on
    next.apply(null, results) if results.length isnt 0 and pending is 0

  next.throw_errors = true

  # Add a special callback generator `this.parallel()` that groups stuff.
  next.parallel = ->
    if arguments.length
      # use for @parallel(-> a, -> b, ...)
      @parallels-setup!
      for fn in arguments => fn.apply(@parallel())
    else
      parallel_index = ++counter
      pending++

      return (err, ...args) ->
        pending--
        # Compress the error from any result to the first argument
        results[0] = err if err
        # Send the other results as arguments
        results[parallel_index] = args[0];
        # When all parallel branches done, call the callback
        next.apply(null, results) if not lock and pending is 0

  # helper for list of actions to parallel
  next.parallels-setup = ->
      steps[--step_index] = (error, ...results) ->
        for cb in results
          if typeof cb is 'function' and cb.length is 2
            cb null, @parallel()
          else
            @parallel()(error, cb)

  # Generates a callback generator for grouped results
  next.group = ->
    localCallback = next.parallel();
    counter := pending := 0; result = []; error = void

    # When group is done, call the callback
    check = -> localCallback(error, ...result) if pending is 0

    # Ensures that check is called at least once
    if process?.nextTick then process.nextTick(check) else setTimeout check, 0

    # Generates a callback for the group
    return (error, ...args) ->
      index = counter++
      pending++
      return ->
        pending--
        # Send the other results as arguments
        result[index] = args[0];
        check() if not lock

  # a common need is to wait for a stream to finish writing
  next.drain = (stream, data) ->
    if not stream.write data
      then stream.once 'drain', @ else @! # synchronous

  # similarly when we pipe we need to wait for it to complate
  next.pipe = (input, output) ->
    input.pipe(output, end: false);
    input.on 'end', @

  # # used to load libraries (such as jQuery) in parallel
  # # this is a shortcut for multiple 'depends 'blah', parallel()
  # next.libraries = (urls...) ->
  #   depends url, @parallel() for url in urls

  # wrapper for dependencies that have asynchronous actions during
  # initialisation. Only for client. Contents need to be
  # module.exports = (error, next) -> init code
  # can include non-asynchronous that return anything, but they
  # must not return a function with two parameters or it will be
  # run.
  next.depends = (...urls) ->
    # after load we call the result with a next action parameter
    @parallels-setup!
    for url in urls => depends url, @parallel()
  # wrapper for library JS files that do not work on the global
  # name-space specifically. It is the same as  <script> tag.
  next.library = (...urls) ->
    # after load we call the result with a next action parameter
    @parallels-setup!
    for url in urls => depends.script-loader url, @parallel()
  next() # Start the engine and pass nothing to the first step.

  # load static data asynchronously
  next.data = (...urls) ->
    for url in urls then depends.data-loader url, @parallel()

module.exports = step
