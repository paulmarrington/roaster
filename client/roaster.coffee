# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see GPL for license

# Simple effective asynchronous module requirements for the browser.

window.slice$ = window['__slice'] = [].slice
window['__bind'] = (fn, me) -> return -> return fn.apply(me, arguments)
window.bind$ = (obj, key, target) ->
  return -> return (target || obj)[key].apply(obj, arguments)

window.roaster =
  depends: (url, domain, next) ->
    # see if we are loaded and ready to go
    return next imports if imports = roaster.cache[url]
    # see if we are in the process of loading
    return roaster.loading[url].push(next) if roaster.loading[url]
    # ok, we are going to need to kick of a synchronous load
    roaster.loading[url] = [next]

    roaster.script_loader url, domain, ->
      imports = roaster.cache[url]
      callbacks = roaster.loading[url]
      while callback = callbacks.pop()
        callback imports if callback
      delete roaster.loading[url]

  script_loader: (url, domain, next) ->
    return next() if roaster.cache[url]
    script = document.createElement("script")
    script.type = "text/javascript"
    script.async = "async"
    if script.readyState # IE
      script.onreadystatechange = ->
        if script.readyState == "loaded" || script.readyState == "complete"
          script.onreadystatechange = null;
          roaster.cache[url] ?= {}
          next()
    else # Other browsers
      script.onload = ->
        roaster.cache[url] ?= {}
        next()

    sep = if url.indexOf('?') is -1 then '?' else '&'
    script.src = "#{url}#{sep}domain=#{domain}"
    document.getElementsByTagName("head")[0].appendChild(script)

  data_loader:  (url, next) ->
    request = new XMLHttpRequest()
    request.open 'GET', url, true
    request.onreadystatechange = ->
      return if request.readyState isnt 4
      switch request.status
        when 200 then next null, request.responseText
        else next request.statusText
    request.send null

  requireSync: (module_name) ->
    # see if we are loaded and ready to go
    return imports if imports = roaster.cache[module_name]
    console.log "If possible move to async step(->@requires '#{module_name}')"
    request = new XMLHttpRequest()
    request.open 'GET', "/#{module_name}.client.node", false
    request.send null
    eval request.responseText

  requireAsync: (module_name, url, next) ->
    # see if we are loaded and ready to go
    return imports if imports = roaster.cache[module_name]
    @depends url, 'client', (imports) =>
      roaster.cache[module_name] = imports
      next(imports)

  scriptIndex: 0
  cache: {}
  loading: {}

roaster.steps = (steps...) ->
  roaster.requireAsync 'events', '/client/events.js', (events) ->
    roaster.events = events
    roaster.depends '/common/steps.coffee', 'client', (Steps) ->
      Steps::depends = (domain, modules) ->
        do depends = ->
          return @next() if not modules.length
          name = modules.shift()
          key = path.basename(name).split('.')[0]
          roaster.depends name, domain, (imports) =>
            @[key] = imports
            depends()
      # possibly asynchronous requires
      Steps::requires = (modules...) -> @depends 'client', modules
      # run server scripts sequentially
      Step::service = (scripts...) -> @depends 'server', modules
      # load static data asynchronously
      Step::data = (urls...) ->
        for url in urls
          done = @parallel()
          key = path.basename(url).split('.')[0]
          roaster.data_loader url, (@error, text) =>
            @[key] = response_text
            done()
      # over-ride loader and run it this first time
      roaster.steps = (steps...) -> new Steps(steps)
      new Steps(steps)

window.server_status =
  start_time: Number.MAX_VALUE
  debug_mode: false

roaster.data_loader '/server/http/status.server.coffee', (error, data) ->
  return if error or not data
  try
    last_server_status = window.server_status
    window.server_status = JSON.parse data
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
