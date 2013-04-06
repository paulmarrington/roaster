# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

module.exports.server_status = roaster.server_status =
  start_time: Number.MAX_VALUE
  debug_mode: false

roaster.request.data_loader '/server/http/status.server.coffee', (error, data) ->
  return if error or not data
  try
    last_server_status = roaster.server_status
    roaster.server_status = JSON.parse data
    last_focus_time = new Date()
    if server_status.debug_mode
      window.onfocus = ->
        now = new Date
        time = Math.floor((now.getTime() - last_focus_time.getTime()) / 1000)
        last_focus_time = now
        if time > 10 and window.confirm("Restart?")
          roaster.script_loader '
            /server/http/terminate.coffee?key=yestermorrow', 'server', ->
              refresh = -> window.location.href = window.location.href
              setTimeout refresh, 2000
          last_focus_time = now
  catch error
