# Copyright (C) 2013 paul@marrington.net, see GPL for license
module.exports = requests =
  data: (url, next) ->
    contents = []
    @stream url, pragma: "no-cache",
    (error, text, is_complete) ->
      contents.push text
      contents = [] if error
      next(error, contents.join('')) if is_complete

  stream: (url, headers..., onData) ->
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
    # CodeMirror insists of CommonJS with a mixed-up path
    if module_name[0] is '.'
      return roaster.cache[module_name] = {}
    request = new XMLHttpRequest()
    try
      request.open 'GET',
        "/#{module_name}.require?domain=client", false
      request.send null
      eval request.responseText
    catch err
      console.log "require '#{module_name}'", err.stack
    return roaster.cache[module_name]

  requireAsync: (module_names..., on_loaded) ->
    modules = []
    do require_module = =>
      if not module_names.length
        return on_loaded(null, modules...)
      name = module_names.shift()
      if imports = roaster.cache[name]
        return require_module modules.push(imports)
      roaster.clients "/#{name}.require", (imports) =>
        roaster.cache[name] = imports
        require_module modules.push(imports)

  # load static data asynchronously
  data_loader: (urls, next) ->
    refs = {}
    base = roaster.path.basename
    do next_one = ->
      return next(null, refs) if not urls.length
      url = urls.shift()
      @key = base(url.split('?')[0]).split('.')[0]
      requests.data url, (error, text) =>
        return next(error) if error
        refs[@key] = text
        next_one()
