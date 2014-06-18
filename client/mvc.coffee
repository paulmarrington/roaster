integrant_cache = {}

module.exports = mvc = (id, name, host, opts, ready) ->
  host = host.templates[0].host if host.templates?[0]?.host
  if not ready and opts instanceof Function
    ready = opts; opts = {}
  opts ?= {}
  activate = ->
    return false if not (module = integrant_cache[name])
    host.innerHTML = module.html
    host.classList.add name
    host.integrant = new module()
    host.integrant[k] = v for k,v of {id,name,host,mvc,opts}
    host.integrant.fetch_templates()
    host.integrant.init (err) -> ready(err, host.integrant)
    return true
  return if activate()
  
  if name[0] is '/'
    base = ''
    name = name[1..-1]
  else
    base = "client/integrants/"
    
  module_html = null
  require.css "#{base}#{name}.css"
  require.data "#{base}#{name}.html", (error, html) ->
    if integrant_cache[name]
      integrant_cache[name].html = html
      activate()
    else
      module_html = html # waiting on script
  module_name = "#{base}#{name}"
  require module_name, (the) ->
    exports = the[module_name]
    exports.html = module_html
    integrant_cache[name] = exports
    activate() if module_html