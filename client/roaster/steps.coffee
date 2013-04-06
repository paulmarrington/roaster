# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

module.exports = roaster.steps = (steps...) ->
  roaster.request.requireAsync 'events', 'util', 'path', (events, util, path) ->
    roaster.depends '/common/steps.coffee', 'client', (Steps) ->
      Steps::depends = (domain, modules) ->
        @asynchronous()
        do depends = =>
          return @next() if not modules.length
          name = modules.shift()
          key = path.basename(name).split('.')[0]
          roaster.depends name, domain, (imports) =>
            @[key] = imports
            depends()
      # possibly asynchronous requires
      Steps::requires = (modules...) -> @depends 'client', modules
      # run server scripts sequentially
      Steps::service = (scripts...) -> @depends 'server', scripts
      # load static data asynchronously
      Steps::data = (urls...) ->
        for url in urls then do =>
          done = @parallel()
          key = path.basename(url).split('.')[0]
          roaster.request.data_loader url, (@error, text) =>
            @[key] = text
            done()
      # Check with server to make sure dependencies are available
      Steps::dependency = (packages) ->
        roaster.json '/server/http/dependency.coffee', packages, @next (data) =>
          for key, value of data
            @error = "No package #{packages[key]}" if not value
      # over-ride loader and run it this first time
      roaster.steps = (steps...) -> new Steps(steps)
      new Steps(steps)
