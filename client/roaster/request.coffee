# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

module.exports =
  data_loader: (url, next) ->
    request = new XMLHttpRequest()
    request.open 'GET', url, true
    request.onreadystatechange = ->
      return if request.readyState isnt 4
      switch request.status
        when 200 then next null, request.responseText
        else next request.statusText
    request.send null

  json:(url, data, next) ->
    blahblahblah

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
