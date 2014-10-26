# Copyright (C) 2014 paul@marrington.net, see /GPL license
vc_cache = {}; sequential = require 'Sequential'

module.exports = (host, opt_list..., ready) ->
  opts = {}  # flatten opts and add DOM attributes to opts
  opts[k] = v for k, v of opt for opt in opt_list
  opts[attr.name] = attr.value for attr in host.attributes
    
  type = opts.vc
  base = if type[0] is '/' then '' else "/client/vc/"

  activate = ->
    return false if not (Integrant = vc_cache[type])
    # vc loaded - activate it
    vc = host.vc = new Integrant()
    if not host.childElementCount
      host.innerHTML = vc.html
    host.classList.add type
    vc.opts = opts
    vc[k] = v for k,v of {type, host, base}
          
    list = host.getElementsByClassName('template')
    vc.templates = []
    while list.length
      vc.templates.push template = list[0]
      name = template.getAttribute('name')
      vc.templates[name] = template if name
      template.hostess = template.parentNode
      template.parentNode.removeChild template
        
    process_contents = (done) ->
      inner = (it for it in host.getElementsByClassName('vc'))
      do process = =>
        return done() if not inner.length
        el = inner.shift()
        return process() if el.vc is vc
        parent = vc.get_vc_for el
        return process() if parent isnt vc
        
        (el.vc = vc).prepare el
        
        vc_type = el.getAttribute('vc')
        return process() if not vc_type
        module.exports el, opts[vc_type] ? {}, process
    
    vc_init = (done) ->
      vc.init(done)
      done() if not vc.init.length # sync
        
    process_initialisers = (done) ->
      sequential.actions vc.initialisers, done
    
    process_contents -> vc_init -> process_initialisers ->
      ready(null, vc)

    return true
  return if activate()

  # come here if vc not loaded from server
  contents = null
  base = "#{base}#{type}"
  require.css "#{base}.css"
  require.data "#{base}.html", (error, html) ->
    contents = html
    if vc_cache[type]
      vc_cache[type]::html = html
      activate()
  base = base[1..-1]
  require 'vc/Integrant', base, (the) =>
    exports = the[base]
    if not exports
      return ready(Error("VC '#{base}' failed"))
    (vc_cache[type] = exports)::html = contents
    activate() if contents