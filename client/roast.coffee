# Copyright (C) 2014 paul@marrington.net, see /GPL for license
window.roaster ?=
  message: (msg...) -> console?.log(msg.join('\n'))
  error:   (msg...) -> roaster.message 'Error: ', msg...
  head:    document.getElementsByTagName('head')[0]
  opts:    {}

parse_require_name = (name) ->
  name = '/' + name if name[0] isnt '/'
  name += ".require" if name.indexOf('.') is -1
  return name

window.require = (name) ->
  return require.cache[name] if require.cache[name]
  # CodeMirror insists on CommonJS with a mixed-up path
  return roaster.cache[next] = {} if name[0] is '.'
  url = parse_require_name name
  request = new XMLHttpRequest()
  request.open 'GET', url, false
  request.send null
  code = request.responseText + "\n//# sourceURL=" + name
  try eval code catch err
    console.log "require '#{next}'", err.stack
  module = require.cache[name] ? require.cache[url]
  module ?= require.cache[name.split('/')[-1..-1]]
  return module?.client ? module

window.require.ready = []
window.require.on_ready = (action) -> require.ready.push action

roaster.cache = require.cache = roaster: roaster
require.opts = roaster.opts

# load a script from the server using <script> tag
require.script = (url, on_loaded = ->) ->
  return on_loaded() if require.cache[url]
  require.cache[url] = true
  sep = if url.indexOf('?') is -1 then '?' else '&'
  url += sep+'domain=client,library'
  script = document.createElement("script")
  script.type = "text/javascript"
  script.async = "async"
  script.onload = script.onerror = script.onabort =
  script.ontimeout = on_loaded
  script.src = url
  roaster.head.appendChild(script)
  
require 'roast/init', ->