# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

roaster.environment = roaster.process.environment = {}

module.exports.load = ->
  roaster.request.data '/server/http/environment.coffee?domain=server',
    (@error, data) =>
      try
        @asynchronous()
        roaster.environment = JSON.parse data
        last_focus_time = new Date()
        if roaster.environment.debug
          window.onfocus = ->
            now = new Date
            time = Math.floor((now.getTime() - last_focus_time.getTime()) / 1000)
            last_focus_time = now
            if time > 10 and window.confirm("Restart?")
              roaster.script_loader '/server/http/terminate.coffee?key=yestermorrow',
                'server', ->
                  refresh = -> window.location.href = window.location.href
                  setTimeout refresh, 2000
              last_focus_time = now
      catch error
      @next()
