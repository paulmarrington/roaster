# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

roaster.environment = roaster.process.environment = {}

refresh = -> window.location.href = window.location.href

roaster.restart = ->
  roaster.script_loader '/server/http/terminate.coffee?key=yestermorrow',
    'server', -> setTimeout refresh, 2000

key_time = 0

add_restart_link = ->
  a = document.createElement("a")
  a.href = "javascript:roaster.restart()"
  a.innerHTML = "restart"
  a.setAttribute 'style', "position:absolute;right:2;top:0"
  document.body.appendChild(a)
  document.onkeydown = ->
    if event.keyCode is 27
      time = new Date().getTime()
      if time - key_time < 500
        roaster.restart()
      else
        key_time = time

module.exports.load = ->
  @asynchronous()
  roaster.request.data '/server/http/environment.coffee?domain=server',
    (@error, data) =>
      try
        roaster.environment = JSON.parse data
        add_restart_link() if roaster.environment.debug
      catch error
      @next()
