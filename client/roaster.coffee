# Copyright (C) 2012 paul@marrington.net, see GPL for license

# Simple effective asynchronous module requirements
# for the browser.

window.slice$ = window['__slice'] = [].slice
window['__bind'] = (fn, me) ->
  return -> return fn.apply(me, arguments)
window.bind$ = (obj, key, target) ->
  return -> return (target || obj)[key].apply(obj, arguments)

pkg_dir = "/client/packages"

window.roaster =
  context: {}
  # run code sequentially once roaster is ready
  on_ready: []
  ready: (func) ->
    return func(->) if not roaster.on_ready
    return roaster.on_ready.push(func) if func.length
    roaster.on_ready.push (next) -> func(); next()
  # Basic dependency loading for scripts
  depends: (url, domain, next) ->
    # see if we are loaded and ready to go
    return next imports if imports = roaster.cache[url]
    # see if we are in the process of loading
    if roaster.loading[url]
      return roaster.loading[url].push(next)
    # ok, we are going to need to kick of a synchronous load
    roaster.loading[url] = [next]

    roaster.script_loader url, domain, ->
      imports = roaster.cache[url]
      callbacks = roaster.loading[url]
      cb imports while cb = callbacks.pop() when cb
      delete roaster.loading[url]

  load: (packages..., next) ->
    packages = packages[0].split(',') if packages.length is 1
    roaster.ready ->
      files = ("#{pkg_dir}/#{pkg}.coffee" for pkg in packages)
      loader = (step, next) ->
        return next() if not packages.length
        pkg = packages.shift()
        step[pkg](-> loader(step, next))
      roaster.steps(
        ->  @requires files...
        ->  loader(@, @next)
        ->  next()
        )

  script_loader: (url, domain, next) ->
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
      script.onload = ->
        roaster.cache[url] ?= {}
        next()

    if domain?.length
      if src[0] == '/' # absolute
        # domain in command over-rides earlier reference
        if src[1] is '!'
          src = src.slice src.indexOf('/', 2) + 1
        # domain in query string takes precedence
        if src.indexOf('domain=') == -1
          src = "/!#{domain}#{src}"
      else # relative, use query form of domain
        src = roaster.add_command_line src, domain: domain

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
    
  global: {}

  cache: {}
  loading: {}
  request: {}

window.process = roaster.process

load_requirements = ->
  @requires(
    '/ext/node_modules/underscore/underscore.js'
    '/client/roaster/environment.coffee'
    '/common/wait_for.coffee'
    '/client/dependency.coffee', '/app.coffee')
    
load_environment = ->
  roaster.dependency = @dependency
  window._ = @underscore
  @environment.load @next

roaster_loaded = ->
  do on_ready = ->
    if not roaster.on_ready.length
      return roaster.on_ready = null
    roaster.on_ready.shift()(on_ready)

roaster.depends '/client/roaster/request.coffee',
'client', (request) ->
  roaster.request = request
  roaster.depends '/client/roaster/steps.coffee',
  'client', (steps) ->
    roaster.cache.steps = steps
    steps(
      load_requirements
      load_environment
      roaster_loaded
    )
