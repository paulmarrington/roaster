# Copyright (C) 2013 paul@marrington.net, see GPL for license

domains =
  library: 'client,library'
  client: 'client'
  server: 'server'
  package: 'package'

module.exports = roaster.steps = (steps...) ->
  requests = roaster.request
  requests.requireAsync 'util', 'events', 'path',
  (events, util, path) ->
    roaster.depends '/common/steps.coffee', 'client',
    (Steps) ->
      class ClientSteps extends Steps
        depends: (domain, modules) ->
          @asynchronous()
          do depends = =>
            return @next() if not modules.length
            name = modules.shift()
            # switch domains on the fly
            if domains[name]
              domain = name
              depends()
            # break up into key, inner and extension
            parts = path.basename(name).split(/\./)
            if parts[0].length then key = parts[0]
            else key = parts[1]
            # no extension means load with node require on server
            if name.indexOf('.') is -1 and domain is 'client'
              return requests.requireAsync name, (imports) =>
                @[key] = imports
                depends()
            # allocate more time to download
            @long_operation()
            # See if it is script or style
            type = parts.slice(-1)[0]
            if roaster.environment?.extensions?[type] is 'css'
              requests.css name
              depends()
            else if domain is 'package'
              roaster.load name, depends
            else
              roaster.depends name, domain, (imports) =>
                from = if name[0] is '/' then 1 else 0
                name = name.slice(from, -(type.length+1))
                @[key] = roaster.cache[name] = imports
                if imports.initialise
                  imports.initialise(depends)
                else
                  depends()
        # possibly asynchronous requires
        requires: (modules...) ->
          @depends 'client', modules
        # for packages that may be downloaded from other sites
        package: (modules...) ->
          @long_operation()
          @depends 'package', modules
        # load client code unwrapped for external libraries
        libraries: (libraries...) ->
          @depends 'client,library', libraries
        # run server scripts sequentially
        service: (scripts...) ->
          @depends 'server', scripts
        # load static data asynchronously
        _data: (urls..., parser) ->
          for url in urls then do =>
            done = @parallel()
            @key = path.basename(url.split('?')[0]).split('.')[0]
            requests.data url, (@error, text) =>
              @[@key] = parser text
              done()
        data: (urls...) ->
          @_data urls..., (text) -> text
        json: (urls...) ->
          @_data urls..., (text) -> JSON.parse text
        # Check server to make sure dependencies are available
        dependency: (packages) ->
          url = roaster.add_command_line(
            '/server/http/dependency.coffee', packages)
          requests.json url,@next (data) =>
            for key, value of data
              @error = "No package #{packages[key]}" if not value
  
      class Queue extends ClientSteps
        # steps.queue -> @require modules..., -> actions
        requires: (modules..., next) ->
          @queue -> super modules...; @queue next
        package: (modules..., next) ->
          @queue -> super modules...; @queue next
        libraries: (libraries..., next) ->
          @queue -> super libraries...; @queue next
        service: (scripts..., next) ->
          @queue -> super scripts...; @queue next
        data: (urls..., next) ->
          @queue -> super scripts...; @queue next
        json: (urls..., next) ->
          @queue -> super scripts...; @queue next
      # over-ride loader and run it this first time
      roaster.Steps = ClientSteps
      roaster.Queue = Queue
      roaster.steps = (steps...) -> new ClientSteps(steps)
      # Used to integrate steps. Can have optional context
      # addressed by @self or as the parameter to the step
      # as in queue @, ->
      roaster.steps.queue = (self..., action) ->
        steps = new Queue(self...)
        action.apply(steps, steps.self)
      # do the original request that sparked off the load...
      new roaster.steps(steps...)
