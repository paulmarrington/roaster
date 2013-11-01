# Copyright (C) 2013 paul@marrington.net, see GPL for license
domains =
  library: 'client,library'
  client: 'client'
  server: 'server'
  package: 'package'

module.exports = requests =
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

  depends: (domain, modules, next) ->
    modules = modules[0].split(',') if modules.length is 1
    refs = {}; path = require 'path'
    do next_one = ->
      return next(null, refs) if not modules.length
      module = modules.shift()
      return next_one(domain = module) if domains[module]
      # break up into key, inner and extension
      parts = path.basename(module).split(/\./)
      if parts[0].length then key = parts[0]
      else key = parts[1]
      type = parts.slice(-1)[0]
      # no extension is load with node require on server
      if module.indexOf('.') is -1 and domain is 'client'
        requests.requireAsync module, (imports) =>
          return next_one(refs[key] = imports)
      # See if it is script or style
      type = parts.slice(-1)[0]
      if roaster.environment?.extensions?[type] is 'css'
        return next_one(requests.css(module))
      # load third-party package from the server
      if domain is 'package'
        return roaster.load(module, next_one)
      # load from server then continue
      roaster.depends module, domain, (imports) =>
        from = if module[0] is '/' then 1 else 0
        module = module.slice(from, -(type.length+1))
        roaster.cache[module] = refs[key] = imports
        return next_one() if not imports.initialise
        imports.initialise(next_one)

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

require = module.exports.requireSync
