# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
# unashamedly cribbed from http://github.com/creationix/step
# in turn inspired by http://github.com/willconant/flow-js

# @throw_errors = true # throw an exception on an error
# @throw_errors = false # call next with error parameter set
# @() # will move a synchronous function to the next step
module.exports = ->
  class Step
    constructor: (steps) ->
      @steps = [].concat steps...
      @step_index = @counter = @pending = 0
      @results = []; @lock = false
      @throw_errors = true
      @next()

    next: (error, args...) =>
      @counter = @pending = 0
      if @step_index >= @steps.length
        throw error if error # no more steps - throw our error
        return  # all done

      fn = @steps[@step_index++] # Get the next step to execute
      @results = []

      try # Run the step in a try/catch block so exceptions don't get out of hand.
        @lock = true;
        result = fn.apply(@, arguments)
      catch exception
        throw exception if @throw_errors
        @next exception # Pass any exceptions on through the next callback

      @lock = false
      # ok, all entries were synchronous so parallel did not get to
      # process them because the lock above was on
      @next.apply(@, @results) if @results.length isnt 0 and @pending is 0

    # Add a special callback generator `this.parallel()` that groups stuff.
    parallel: =>
      if arguments.length
        # use for @parallel(-> a, -> b, ...)
        @parallels_setup()
        return fn.apply({next:@parallel()}) for fn in arguments
      else
        parallel_index = ++@counter
        @pending++

        return (error, args...) =>
          @pending--
          # Compress the error from any result to the first argument
          @results[0] = error if error
          # Send the other results as arguments
          @results[parallel_index] = args[0];
          # When all parallel branches done, call the callback
          @next.apply(@, @results) if not @lock and @pending is 0

    # helper for list of actions to parallel
    parallels_setup: ->
      @steps[--@step_index] = (error, results...) ->
        for cb in results
          if typeof cb is 'function' and cb.length is 2
            cb error, @parallel()
          else
            @parallel()(error, cb)

    # Generates a callback generator for grouped results - paralell but dynamic list
    # group = @group(); func ..., group(); repeat...
    group: ->
      localCallback = @parallel();
      @counter = @pending = 0; result = []; error = null

      # When group is done, call the callback
      check = -> localCallback(error, result...) if @pending is 0

      # Ensures that check is called at least once
      if process?.nextTick then process.nextTick(check) else setTimeout check, 0

      # Generates a callback for the group
      return (error, args...) =>
        index = @counter++
        @pending++
        return =>
          @pending--
          # Send the other results as arguments
          result[index] = args[0];
          check() if not @lock