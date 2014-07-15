integrant_cache = {}

module.exports = mvc = (picture, host, ready) ->
  type = picture.mvc
  base = if type[0] is '/' then '' else "/client/integrants/"

  activate = ->
    return false if not (module = integrant_cache[type])
    host.innerHTML = module.html
    host.classList.add type
    integrant = host.integrant = new module()
    host.walk = (path) -> integrant.walk(path)
    integrant[k] = v for k,v of {type, host, mvc}
    integrant.fetch_templates()
    
    return ready(err, host) if not picture.cargo
      
    integrant.children ?= {}
    names = (name for name of picture.cargo)
    do next = ->
      if not names.length
        return integrant.init (err) -> ready(err, host)
      data = picture.cargo[item = names.shift()]
      integrant.append data, (err, child) ->
        child.parent_integrant = integrant
        child.select = -> integrant.select(item)
        child.classList.add item
        next integrant.children[item] = child
    return true
  return if activate()
    
  module_html = null
  module_name = "#{base}#{type}"
  require.css "#{module_name}.css"
  require.data "#{module_name}.html", (error, html) ->
    if integrant_cache[type]
      integrant_cache[type].html = html
      activate()
    else
      module_html = html # waiting on script
  module_name = module_name[1..-1]
  require module_name, (the) ->
    exports = the[module_name]
    exports.html = module_html
    integrant_cache[type] = exports
    activate() if module_html