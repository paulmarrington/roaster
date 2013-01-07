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

window.depends = (url, callback = (dependency) -> return dependency) ->  
  # see if we are loaded and ready to go
  return callback dependency if dependency = depends.cache[url]
  # see if we are in the process of loading
  return depends.loading[url].push(callback) if depends.loading[url]
  # ok, we are going to need to kick of a synchronous load
  depends.loading[url] = [callback]
  global_var = "_dependency_#{depends.scriptIndex++}"

  script = document.createElement("script")
  script.type = "text/javascript"
  script.async = "async"
  onScriptLoaded = ->
    window[global_var]?(module = {exports:{}})
    dependency = depends.cache[url] = module?.exports ? {}
    delete window[global_var]
    callbacks = depends.loading[url]
    callback dependency while callback = callbacks.pop()
    delete depends.loading[url]

  if script.readyState # IE
    script.onreadystatechange = ->
      if script.readyState == "loaded" || script.readyState == "complete"
        script.onreadystatechange = null;
        onScriptLoaded();
  else # Other browsers
   script.onload = -> onScriptLoaded()

  script.src = "/server/http/wrap_client_dependency.coffee?url=#{url}&global_var=#{global_var}"
  head ?= document.getElementsByTagName("head")[0]
  head.appendChild(script)

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
depends.forceReload = (url) -> delete depends.cache[url]