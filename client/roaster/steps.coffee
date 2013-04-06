# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

module.exports = roaster.steps = (steps...) ->
  roaster.request.requireAsync 'events', 'util', 'path', (events, util, path) ->
    roaster.depends '/common/steps.coffee', 'client', (Steps) ->
      Steps::depends = (domain, modules) ->
        @asynchronous()
        do depends = =>
          return @next() if not modules.length
          name = modules.shift()
          parts = path.basename(name).split(/\W/)
          key = parts[0]
          type = parts.slice(-1)[0]
          if roaster.server_status?.extensions?[type] is 'css'
            roaster.request.css name
            depends()
          else
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
