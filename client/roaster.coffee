# Copyright (C) 2012,14 paul@marrington.net, see /GPL license

window.slice$ = window['__slice'] = [].slice
window['__bind'] = (fn, me) ->
  return -> return fn.apply(me, arguments)
window.bind$ = (obj, key, target) ->
  return -> return (target || obj)[key].apply(obj, arguments)

pkg_dir = "/client/packages"

window.global = {}

window.roaster =
  context: {}
  # run code sequentially once roaster is ready
  on_ready: []
  file_type: (name) ->
    name.substr((~-name.lastIndexOf(".") >>> 0) + 2)
  ready: (func) ->
    return func(->) if not roaster.on_ready
    return roaster.on_ready.push(func) if func.length
    roaster.on_ready.push (next) -> func(); next()
  preload: (modules...) ->
    return roaster.cache.wait_for (next) ->
      roaster.clients modules..., next
  clients: (paths..., next) ->
    if paths.length is 0 # no cb means synchronous
      return roaster.request.requireSync next
    modules = []
    do load_one = ->
      return next(modules...) if not paths.length
      client paths.shift(), (module) ->
        modules.push module
        load_one()
  # load list of packages
  packages: (packages..., next) ->
    do load_one = ->
      return next() if not packages.length
      pkg = "#{pkg_dir}/#{packages.shift()}.coffee"
      roaster.clients pkg, (pkg) -> pkg(load_one)
  libraries: (libraries..., next) ->
    do load_one = ->
      return next() if not libraries.length
      lib = libraries.shift()
      switch roaster.file_type(lib)
        when 'css'
          roaster.request.css(lib); load_one()
        else
          roaster.depends lib, 'client,library', load_one
  # Basic dependency loading for scripts
  depends: (url, domain, next) ->
    key = url.split('.')[0]
    # see if we are loaded and ready to go
    return next imports if imports = roaster.cache[key]
    # see if we are in the process of loading
    if roaster.loading[url]
      return roaster.loading[url].push(next)
    # ok, we are going to need to kick of a synchronous load
    roaster.loading[url] = [next]

    roaster.script_loader url, domain, ->
      imports = roaster.cache[key]
      callbacks = roaster.loading[url]
      cb imports while cb = callbacks.pop() when cb
      delete roaster.loading[url]

  script_loader: (url, domain..., next) ->
    return next() if roaster.cache[url]
    script = document.createElement("script")
    script.type = "text/javascript"
    script.async = "async"

    [src, attributes] = url.split('#')
    if attributes
      for key, value of roaster.parse_query_string attributes
        script.setAttribute(key, value)

    if script.readyState # IE
      script.onreadystatechange = ->
        ready = script.readyState
        if ready == "loaded" || ready == "complete"
          script.onreadystatechange = null
          roaster.cache[url] ?= {}
          next()
    else # Other browsers
      script.onload = script.onerror =
      script.onabort = script.ontimeout = ->
        roaster.cache[url] ?= {}
        next()

    if domain.length
      if src[0] == '/' # absolute
        # domain in command over-rides earlier reference
        if src[1] is '!'
          src = src.slice src.indexOf('/', 2) + 1
        # domain in query string takes precedence
        if src.indexOf('domain=') == -1
          src = "/!#{domain[0]}#{src}"
      else # relative, use query form of domain
        src = roaster.add_command_line src, domain: domain[0]

    script.src = src
    document.getElementsByTagName("head")[0].
      appendChild(script)

  add_command_line: (url, args) ->
    sep = if url.indexOf('?') is -1 then '?' else '&'
    items = ("#{key}=#{value}" for key, value of args)
    return "#{url}#{sep}#{items.join('&')}"

  parse_query_string: (qs) ->
    result = {}
    for key in qs.split '&'
      value = ''
      if equals = key.indexOf '='
        value = key.substr equals + 1
        key = key.substr 0, equals
      result[key] = value
    return result

  process:
    noDeprecation: true
    platform: 'browser'
    env: {}
    
  global: window.global

  cache: {}
  loading: {}
  request: {}

window.process = roaster.process
window.require = roaster.clients

client = (path, next) ->
  match = /.*\/([\w\-]+)\.\w*/.exec(path)
  return console.log "No client '#{path}'" if not match
  roaster.depends path, 'client', (module =  {}) ->
    roaster.cache[match[1]] = module
    if module.initialise
      module.initialise -> next(module)
    else
      next(module)
    
client '/client/roaster/request.coffee', (request) ->
  roaster.request = request
  roaster.cache.npm = request.requireAsync
  libs = ['util', 'events', 'path']
  request.requireAsync libs..., (err, imports...) ->
    roaster[lib] = imports.shift() for lib in libs
    requirements = [
      '/ext/node_modules/underscore/underscore.js'
      '/client/roaster/environment.coffee'
      '/common/wait_for.coffee'
      '/client/dependency.coffee'
       '/app.coffee'
    ]
    roaster.clients requirements..., ->
      window._ = roaster.cache.underscore
      roaster.cache.environment.load ->
        do on_ready = ->
          if not roaster.on_ready.length
            return roaster.on_ready = null
          roaster.on_ready.shift()(on_ready)
