# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
# unashamedly cribbed from http://github.com/creationix/step
# in turn inspired by http://github.com/willconant/flow-js

# @throw_errors = true # throw an exception on an error
# @throw_errors = false # call next with error parameter set
# @() # will move a synchronous function to the next step
step = (steps...) ->
  step_index = counter = pending = 0
  results = []
  lock = false

  # Define the main callback that's given as `this` to the steps.
  next = (err, args...) ->
    counter = pending = error = 0
    if step_index >= steps.length # all done
      throw err if err # no more steps - throw our error
      return  # all done

    fn = steps[step_index++] # Get the next step to execute
    results = []

    try # Run the step in a try/catch block so exceptions don't get out of hand.
      lock = true;
      result = fn.apply(next, arguments)
    catch exception
      throw exception if @throw_errors
      next exception # Pass any exceptions on through the next callback

    if counter > 0 and pending is 0
      # If parallel() was called, and all parallel branches executed
      # synchronously, go on to the next step immediately.
      next.apply(null, results)
    # else if result isnt undefined
    #   # If a synchronous return is used, pass it to the callback
    #   next(undefined, result)
    
    lock = false

  # Add a special callback generator `this.parallel()` that groups stuff.
  next.parallel = ->
    parallel_index = ++counter
    pending++

    return (err, args...) ->
      pending--
      # Compress the error from any result to the first argument
      results[0] = err if err
      # Send the other results as arguments
      results[parallel_index] = args[0];
      if not lock and pending is 0
        # When all parallel branches done, call the callback
        next.apply(null, results);

  # Generates a callback generator for grouped results
  next.group = ->
    localCallback = next.parallel();
    counter = pending = 0; result = []; error = undefined

    check = -> # When group is done, call the callback
      localCallback(error, result...) if pending is 0

    # Ensures that check is called at least once
    if process?.nextTick then process.nextTick(check) else setTimeout check, 0

    # Generates a callback for the group
    return (error, args...) ->
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
      stream.once 'drain', @
    else
      @()  # synchronous

  # similarly when we pipe we need to wait for it to complate
  next.pipe = (input, output) ->
    input.pipe(output, end: false);
    input.on 'end', @

  next() # Start the engine an pass nothing to the first step.

# Tack on leading and tailing steps for input and output and return
# the whole thing as a function.  Basically turns step calls into function
# factories.
# step.fn = (steps...) ->
#   return (args...) ->
#     # Insert a first step that primes the data stream
#     toRun = [-> this.apply(null, args)].concat(steps);
#     # If the last arg is a function add it as a last step
#     toRun.push(args[-1]) if typeof args[-1] is 'function'
#     step.apply(null, toRun)

module.exports = step