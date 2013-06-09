# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

module.exports =
  data: (url, next) ->
    contents = []
    @stream url, (error, text, is_complete) ->
      contents.push text
      next(error, contents.join('')) if is_complete
    
  stream: (url, onData) ->
    request = new XMLHttpRequest()
    request.open 'GET', url, true
    previous_length = 0
    request.onreadystatechange = ->
      return if request.readyState <= 2
      try
        text = request.responseText.substring(previous_length)
        previous_length += request.responseText.length
      catch e then text = ''
      error = null
      if is_complete = (request.readyState is 4)
        if request.status isnt 200 then error = request.statusText
      onData(error, text, is_complete)
    request.send null

  css: (url) ->
    #<link rel="stylesheet" type="text/css" href="/scratch/test.less">
    link = document.createElement("link")
    link.type = "text/css"
    link.rel = 'stylesheet'
    link.href = url
    document.getElementsByTagName("head")[0].appendChild(link)

  json: (url, next) ->
    @data url, (error, text) ->
      next(error) if error
      next null, JSON.parse text

  requireSync: (module_name) ->
    # see if we are loaded and ready to go
    return imports if imports = roaster.cache[module_name]
    console.log "If possible move to async step(->@requires '#{module_name}')"
    request = new XMLHttpRequest()
    request.open 'GET', "/#{module_name}.requires.js?domain=client", false
    request.send null
    eval request.responseText

  requireAsync: (module_names..., on_loaded) ->
    modules = []
    do require_module = =>
      return on_loaded(modules...) if not module_names.length
      name = module_names.shift()
      if imports = roaster.cache[name]
        return require_module modules.push(imports)
      roaster.depends "/#{name}.require.js", 'client', (imports) =>
        require_module modules.push(roaster.cache[name] = imports)
