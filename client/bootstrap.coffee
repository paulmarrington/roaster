# Copyright (C) 2014 paul@marrington.net, see /GPL for license
window.require ?= opts: {}; window.roaster ?= {}

parse_require_name = (name) ->
  name += ".require" if name.indexOf('.') is -1
  return name

window.require = (module_names..., next) ->
  if module_names.length is 0 # synchronous require
    return require.cache[next] if require.cache[next]
    # CodeMirror insists of CommonJS with a mixed-up path
    return roaster.cache[next] = {} if next[0] is '.'
    url = parse_require_name next
    request = new XMLHttpRequest()
    request.open 'GET', url, false
    request.send null
    try eval request.responseText catch err
      console.log "require '#{next}'", err.stack
    module = require.cache[next] ? require.cache[url]
    return module?.client ? module
 # asynchronous require
  modules = {}; loaded = 0
  load = (name) ->
    if require.cache[name]
      return modules[name] = require.cache[name]
    url = parse_require_name name
    loaded++
    require._script parse_require_name(name), ->
      module = require.cache[name]
      modules[name] = module?.client ? module
      next modules if --loaded is 0 # all loaded
        
  for names in module_names
    for name in names.split(',')
      load(name, modules.length)
  next modules if loaded is 0 # no server loads
          
roaster.cache = require.cache = {}; require.opts ?= {}
roaster.head = document.getElementsByTagName('head')[0]

# load a script from the server using <script> tag
require._script = (url, on_loaded) ->
  script = document.createElement("script")
  script.type = "text/javascript"
  script.async = "async"
  script.onload = script.onerror = script.onabort =
  script.ontimeout = on_loaded
  script.src = url
  roaster.head.appendChild(script)
require.script = (url, on_loaded = ->) ->
  sep = if url.indexOf('?') is -1 then '?' else '&'
  url += sep+'domain=client,library'
  require._script url, on_loaded
  
require 'bootstrap/init', ->