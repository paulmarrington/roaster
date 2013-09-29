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
        set_import: (key, value) -> @[key] = value
        # base requirement loader (client and server)
        depends: (domain, modules) ->
          @long_operation(); @asynchronous()
          # actions that must be sequential
          acts = []
          res = null; results = []
          reserve = ->
            results.push(null)
            return results.length - 1
          # make them available for queueing before set
          for module in modules then do =>
            return res = module if module instanceof Function
            # switch domains on the fly
            return domain = module if domains[module]
            # break up into key, inner and extension
            parts = path.basename(module).split(/\./)
            if parts[0].length then key = parts[0]
            else key = parts[1]
            type = parts.slice(-1)[0]
            name = module
            # no extension is load with node require on server
            if name.indexOf('.') is -1 and domain is 'client'
              do =>
                ri = reserve()
                return acts.push (cb) =>
                  requests.requireAsync name, (imports) =>
                    results[ri] = imports
                    @set_import key, imports
                    cb()
            # See if it is script or style
            type = parts.slice(-1)[0]
            if roaster.environment?.extensions?[type] is 'css'
              reserve()
              return requests.css name
            # load third-party package from the server
            if domain is 'package'
              reserve()
              return acts.push (cb) -> roaster.load name, cb
            # so we can reference import before it is loaded
            # only works for function imports
            module_imports = null
            @set_import key, ->
              module_imports.apply(@, arguments)
            # load from server then continue
            acts.push (cb) => do =>
              ri = reserve()
              roaster.depends name, domain, (imports) =>
                module_imports = imports
                from = if name[0] is '/' then 1 else 0
                name = name.slice(from, -(type.length+1))
                results[ri] = imports
                roaster.cache[name] = @set_import key, imports
                if imports.initialise
                  imports.initialise(cb)
                else
                  cb()
          # load everything in order
          acts.push(-> res(results...)) if res?
          @sequence acts
          #@steps.unshift(acts.pop()) while acts.length
          #@next()
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
          base = path.basename
          for url in urls then do =>
            if url not instanceof Function
              done = @parallel()
              @key = base(url.split('?')[0]).split('.')[0]
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
              if not value
                @error = "No package #{packages[key]}"
  
      class Queue extends ClientSteps
        # imported code can be called asynchronously
        set_import: (k, v) -> @[k] = Steps.modex(v)
        # steps.queue -> @requires modules..., -> actions
        requires: @modex(ClientSteps::requires)
        package: @modex(ClientSteps::package)
        libraries: @modex(ClientSteps::libraries)
        service: @modex(ClientSteps::service)
        data: @modex(ClientSteps::data)
        json: @modex(ClientSteps::json)
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
