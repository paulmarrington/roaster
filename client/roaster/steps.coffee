# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

domains =
  library: 'client,library'
  client: 'client'
  server: 'server'
  package: 'package'

module.exports = roaster.steps = (steps...) ->
  roaster.request.requireAsync 'events', 'util', 'path', (events, util, path) ->
    roaster.depends '/common/steps.coffee', 'client', (Steps) ->
      Steps::depends = (domain, modules) ->
        @asynchronous()
        do depends = =>
          return @next() if not modules.length
          name = modules.shift()
          # switch domains on the fly
          if domains[name]
            domain = name;
            depends()
          # no extension means load with node require on server
          if name.indexOf('.') is -1 and domain is 'client'
            return roaster.request.requireAsync name, depends
          # allocate more time to download
          @long_operation()
          # See if it is script or style
          parts = path.basename(name).split(/\W/)
          key = parts[0]
          type = parts.slice(-1)[0]
          if roaster.environment?.extensions?[type] is 'css'
            roaster.request.css name
            depends()
          else if domain is 'package'
            roaster.load name, depends
          else
            roaster.depends name, domain, (imports) =>
              from = if name[0] is '/' then 1 else 0
              name = name.slice(from, -(type.length+1))
              @[key] = roaster.cache[name] = imports
              depends()
      # possibly asynchronous requires
      Steps::requires = (modules...) -> @depends 'client', modules
      # for packages that may be downloaded from other sites
      Steps::package = (modules...) ->
        @long_operation()
        @depends 'package', modules
      # load client code unwrapped for external libraries
      Steps::libraries = (libraries...) -> @depends 'client,library', libraries
      # run server scripts sequentially
      Steps::service = (scripts...) -> @depends 'server', scripts
      # load static data asynchronously
      Steps::data = (urls...) ->
        for url in urls then do =>
          done = @parallel()
          key = path.basename(url).split('.')[0]
          roaster.request.data url, (@error, text) =>
            @[key] = text
            done()
      # Check with server to make sure dependencies are available
      Steps::dependency = (packages) ->
        url = roaster.add_command_line '/server/http/dependency.coffee', packages
        roaster.request.json url,@next (data) =>
          for key, value of data
            @error = "No package #{packages[key]}" if not value
      # over-ride loader and run it this first time
      roaster.steps = (steps...) -> new Steps(steps)
      new Steps(steps)
