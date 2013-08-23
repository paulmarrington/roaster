# Copyright (C) 2013 paul@marrington.net, see GPL for license

module.exports =
  data: (url, next) ->
    contents = []
    @stream url, (error, text, is_complete) ->
      contents.push text
      contents = [] if error
      next(error, contents.join('')) if is_complete

  stream: (url, onData) ->
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
    request.send null

  css: (url) ->
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
    console.log "If possible move to async step(->@requires"+
      "'#{module_name}')"
    request = new XMLHttpRequest()
    request.open 'GET',
      "/#{module_name}.require.js?domain=client", false
    request.send null
    eval request.responseText

  requireAsync: (module_names..., on_loaded) ->
    modules = []
    do require_module = =>
      return on_loaded(modules...) if not module_names.length
      name = module_names.shift()
      if imports = roaster.cache[name]
        return require_module modules.push(imports)
      roaster.depends "/#{name}.require.js",
      'client', (imports) =>
        roaster.cache[name] = imports
        require_module modules.push(imports)
