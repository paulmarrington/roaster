# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

roaster.environment = roaster.process.environment = {}

reload = -> window.location.href = window.location.href

roaster.restart = ->
  $('body').hide()
  roaster.script_loader '/server/http/terminate.coffee?key=yestermorrow',
    'server', -> setTimeout reload, 2000

key_time = 0

add_restart_link = ->
  a = document.createElement("a")
  a.href = "javascript:roaster.restart()"
  a.innerHTML = "restart"
  a.setAttribute 'style', "position:absolute;right:2;top:0;z-index:1000000"
  a.setAttribute 'title', "Or press <esc><esc>"
  document.body.appendChild(a)
  window.onkeydown = ->
    if event.keyCode is 27
      time = new Date().getTime()
      elapsed = time - key_time
      if 250 > elapsed > 50
        roaster.restart()
      else
        key_time = time

module.exports.load = (next) ->
  roaster.request.data '/server/http/environment.coffee?domain=server',
    (@error, data) =>
      try
        roaster.environment = JSON.parse data
        add_restart_link() if roaster.environment.debug
      catch error
      next()
