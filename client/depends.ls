# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# Simple effective asynchronous module requirements for the browser.

# Dependencies are only loaded once - the first time they are referenced. Afterwards
# the same in-memory instance is used. By using 'depends' when the information is
# referenced in a parent module means that code is loaded on demand - giving a responsive
# UI without resorting to combining script files.

# If run on the uSDLC-node-server, translation to js from coffeescript, etc is transparent.
# This means any supported language will work (coffee-script, live-script, clojure-script, etc)

# In the example below script 'a' depends on script 'b'. The closure is only run
# after script 'b' was loaded. Script 'b' in turn relies on script 'c'. In the end
# the log is only written to and the value checked after scripts a, b and c are all
# loaded.

# #a.coffee:
# depends 'b', (b) ->
#   console.log b.name
#   throw 'wrong' if b.value isnt 1

#   depends 'c', (c) ->
#     throw 'wrong' if c() isnt 2

#     depends.forceReload 'c'
#     depends 'c', (c) ->
#       throw 'wrong' if c isnt 1 # reset as c.js is reloaded

# #b.coffee
# ->
#   depends 'c', (c) ->
#     return
#       name: "bee"
#       value: c()

# #c.js
# function() {
#   counter = 1
#   return function() {counter++}
# }
head = null

window.depends = (url, next) ->
  [url, query] = url.split '?'
  # see if we are loaded and ready to go
  return next null, dependency if dependency = depends.cache[url]
  # see if we are in the process of loading
  return depends.loading[url].push(next) if depends.loading[url]
  # ok, we are going to need to kick of a synchronous load
  depends.loading[url] = [next]
  global_var = "_dependency_#{depends.scriptIndex++}"

  query = "#{url}?global_var=#{global_var}&#{query ? 'domain=client.depends'}"
  depends.script-loader query, ->
    window[global_var]?(module = {exports:{}})
    dependency = depends.cache[url] = module?.exports ? {}
    delete window[global_var]
    callbacks = depends.loading[url]
    while callback = callbacks.pop()
      callback null, dependency if callback
    delete depends.loading[url]

depends.script-loader = (url, next) ->
  script = document.createElement("script")
  script.type = "text/javascript"
  script.async = "async"
  if script.readyState # IE
    script.onreadystatechange = ->
      if script.readyState == "loaded" || script.readyState == "complete"
        script.onreadystatechange = null;
        next();
  else # Other browsers
    script.onload = -> next()

  script.src = url
  head ?= document.getElementsByTagName("head")[0]
  head.appendChild(script)

depends.data-loader = (url, next) ->
  request = new XMLHttpRequest()
  request.open 'GET', url, true
  request.onreadystatechange = (event) ->
    return if request.readyState isnt 4
    switch request.status
      | 200 => next null, request.responseText
      | otherwise => next request.statusText
  request.send null

depends.scriptIndex = 0
depends.cache = {}; depends.loading = {}

# # Use depends.ready to run a callback when all listed dependencies are loaded.
# # Value added depends will return the dependency if we know it has loaded.
# depends.ready = (urls..., callback) ->
#   unloaded = (url for url in urls when depends.cache[url])
#   to_load = unloaded.length
#   return callback() if to_load is 0

  # aggregate_callback = -> callback() if --to_load is 0
  # depends url, aggregate_callback for url in unloaded

# Use forceReload if a module source has changed (edited on browser, for example)
depends.force-reload = (url) -> delete depends.cache[url]

# step() is so often used with depends that it makes sense to load it the
# first time it is called
window.step = (...steps) ->
  depends '/common/step.ls', (errror, step) ->
    window.step = step
    step ...steps

window.server-status =
  start-time: Number.MAX_VALUE
  debug-mode: false

get-server-status = ->
  depends.data-loader '/server/http/status.server.ls', (error, data) ->
    # return setTimeout(get-server-status, 5000) if error or not data
    try
      last-server-status = window.server-status
      window.server-status = JSON.parse data
      if server-status.debug-mode
        if window.server-status.start-time > last-server-status.start-time
          window.location.href = window.location.href
          return
        request = new XMLHttpRequest()
        request.open 'GET', '/server/http/alive.server.ls', true
        request.onreadystatechange = (event) ->
          if request.readyState is 4
            setTimeout get-server-status, 1000
        request.send null
    catch
      setTimeout get-server-status, 1000

get-server-status!
