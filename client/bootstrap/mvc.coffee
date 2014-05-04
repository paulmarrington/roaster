integrant_cache = {}

roaster.mvc = (name, host, opts..., ready) ->
  host = host.host if host.host # element or integrant works
  activate = ->
    return false if not (module = integrant_cache[name])
    host.innerHTML = module.html
    host.classList.add name
    instance = new module(host, opts...)
    instance.host = host
    ready null, instance
    return true
  return if activate()
  
  if name[0] is '/'
    base = ''
    name = name[1..-1]
  else
    base = "client/integrants/"
    
  module_html = null
  require.css "#{base}#{name}"
  require.data "#{base}#{name}.html",
  (error, html) ->
    if integrant_cache[name]
      integrant_cache[name].html = html
      activate()
    else
      module_html = html # waiting on script
  require "#{base}#{name}", (exports) ->
    exports.html = module_html
    integrant_cache[name] = exports
    activate() if module_html
