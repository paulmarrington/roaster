# Copyright (C) 2014 paul@marrington.net, see /GPL license
sequential = require 'Sequential'

require.file_type = (name) ->
  name.substr((~-name.lastIndexOf(".") >>> 0) + 2)

require.build_url = (url, args) ->
  sep = if url.indexOf('?') is -1 then '?' else '&'
  items = ("#{key}=#{value}" for key, value of args)
  return "#{url}#{sep}#{items.join('&')}"

require.dependency = (packages, libraries..., ready) ->
  url = require.build_url \
    '/server/http/dependency.coffee', packages
  require.json url, -> do load_one = ->
    return ready() if not libraries.length
    lib = libraries.shift()
    switch require.file_type(lib)
      when 'css'
        require.css lib; load_one()
      else
        require.script lib, load_one

require.packages = (packages..., ready) ->
  do load_one = ->
    return ready() if not packages.length
    name = packages.shift()
    require("client/packages/#{name}") load_one

require.json = (url, on_loaded) ->
  @data url, (error, text) ->
    return on_loaded(error) if error
    on_loaded null, JSON.parse text

require.css = (urls...) ->
  for url in urls
    return if require.cache[url]
    require.cache[url] = true
    link = document.createElement("link")
    link.type = "text/css"
    link.rel = 'stylesheet'
    link.href = url
    head = document.getElementsByTagName("head")[0]
    head.appendChild(link)
    
require.static = (url, next) -> require.data url, next, {}
  
require.data = (url, next, headers = pragma: "no-cache") ->
  contents = []
  @stream url, headers, (error, text, is_complete) ->
    contents.push text
    contents = [] if error
    next(error, contents.join('')) if is_complete
      
require.stream = (url, headers..., onData) ->
  url += '.script' if url.indexOf('.') is -1
  request = new XMLHttpRequest()
  previous_length = 0
  request.onreadystatechange = ->
    return if request.readyState <= 2
    try
      text = request.responseText.substring(previous_length)
      previous_length = request.responseText.length
    catch e then text = ''
    error = null
    if is_complete = (request.readyState is 4)
      if request.status isnt 200
        error = request.statusText
    onData(error, text, is_complete)
  request.open 'GET', url, true
  for header in headers
    request.setRequestHeader(k, v) for k, v of header
  request.send null
