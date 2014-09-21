integrant_cache = {}; sequential = require 'Sequential'

module.exports = mvc = (picture, host, ready) ->
  type = picture.mvc; host.container ?= host
  base = if type[0] is '/' then '' else "/client/integrants/"

  activate = ->
    return false if not (module = integrant_cache[type])
    host.container.innerHTML = module.html
    host.classList.add type
    integrant = host.integrant = new module()
    host.walk = (path) -> integrant.walk(path)
    host.picture = picture
    integrant[k] = v for k,v of {type, host, mvc, base}
    integrant.fetch_templates()

    process_contents = (done) =>
      sequential.object picture, done, (key, next) =>
        action = integrant[key]
        return next() if not action or key in ["mvc"]
        action.call(integrant, picture[key], next)
        next() if action.length < 2 # sync
    
    process_initialisers = (done) =>
      sequential.actions integrant.initialisers, done
      
    integrant_init = (done) =>
      integrant.init(done)
      done() if not integrant.init.length # sync

    process_contents -> integrant_init ->
      process_initialisers -> ready(null, host)

    return true
  return if activate()
    
  module_html = null
  base = "#{base}#{type}"
  require.css "#{base}.css"
  require.data "#{base}.html", (error, html) ->
    if integrant_cache[type]
      integrant_cache[type].html = html
      activate()
    else
      module_html = html # waiting on script
  base = base[1..-1]
  require 'Integrant', base, (the) =>
    exports = the[base]
    return ready(Error("MVC '#{base}' failed")) if not exports
    exports.html = module_html
    integrant_cache[type] = exports
    activate() if module_html