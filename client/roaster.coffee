# Copyright (C) 2012 Paul Marrington (paul@marrington.net), see GPL for license

# Simple effective asynchronous module requirements for the browser.

window.slice$ = window['__slice'] = [].slice
window['__bind'] = (fn, me) -> return -> return fn.apply(me, arguments)
window.bind$ = (obj, key, target) ->
  return -> return (target || obj)[key].apply(obj, arguments)

window.roaster =
  # run code sequentially once roaster is ready
  on_ready: []
  ready: (func) ->
    return func(->) if not roaster.on_ready
    return roaster.on_ready.push(func) if func.length
    roaster.on_ready.push (next) -> func(); next()
  # Basic dependency loading for scripts
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
      callback imports while callback = callbacks.pop() when callback
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

  process:
    noDeprecation: true
    platform: 'browser'

  cache: {}
  loading: {}
  request: {}

roaster_loaded = ->
  do on_ready = ->
    return roaster.on_ready = null if not roaster.on_ready.length
    roaster.on_ready.shift()(on_ready)

roaster.depends '/client/roaster/request.coffee', 'client', (request) ->
  roaster.request = request
  roaster.depends '/client/roaster/steps.coffee', 'client', (steps) ->
    steps(
      ->  @requires '/client/roaster/server_status.coffee'
      ->  roaster.server_status = @server_status
      ->  @requires '/app.coffee'
      ->  roaster_loaded()
    )
