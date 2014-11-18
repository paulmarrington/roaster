# Copyright (C) 2014 paul@marrington.net, see /GPL license
vc_cache = {}; sequential = require 'Sequential'

module.exports = (host, opt_list..., ready) ->
  container_html = host.innerHTML
  opts = {}  # flatten opts and add DOM attributes to opts
  opts[k] = v for k, v of opt for opt in opt_list
  opts[attr.name] = attr.value for attr in host.attributes
    
  type = opts.vc
  base = if type[0] is '/' then '' else "/client/vc/"

  activate = ->
    return false if not (Integrant = vc_cache[type])
    # vc loaded - activate it
    vc = new Integrant(host)
    if vc.shared_host and host.getAttribute("vc") isnt vc.type
      host = host.appendChild document.createElement 'DIV'
    if vc.using_html_view
      vc.container_html = ""
      host.classList.add type
    else
      vc.container_html = container_html
      host.innerHTML = vc.view_html
    host.vc = vc; vc.opts = opts
    vc[k] = v for k,v of {type, host, base}
          
    list = host.getElementsByClassName('template')
    vc.templates = []
    while list.length
      vc.templates.push template = list[0]
      name = template.getAttribute('name')
      vc.templates[name] = template if name
      template.hostess = template.parentNode
      template.parentNode.removeChild template
    # add templates from loaded html file
    if vc.using_html_view
      for name,template of vc.named_templates
        if not vc.templates[name]
          vc.templates[name] = template.cloneNode(true)
          vc.templates[name].hostess = vc.host
        
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
        module.exports el, opts[vc_type] ? {},
          using_html_view: true, process
    
    vc_init = (done) ->
      if vc.container = vc.owned("container")
        vc.container.innerHTML = vc.container_html
      vc.init(done)
      done() if not vc.init.length # sync
        
    process_initialisers = (done) ->
      sequential.actions vc.initialisers, done
    
    process_contents -> vc_init -> process_initialisers ->
      ready(null, vc)

    return true
  
  return if activate()
  # come here if vc not loaded from server
  base = "#{base}#{type}"
  require.css "#{base}.css"
  vc_cache[type] = require base[1..-1]
  require.static "#{base}.html", (error, html) ->
    (div = document.createElement("div")).innerHTML = html
    list = div.getElementsByClassName('template')
    vc_cache[type]::named_templates = {}
    for tpl in list when name = tpl.getAttribute('name')
      vc_cache[type]::named_templates[name] = tpl
    
    vc_cache[type]::view_html = html
    vc_cache[type]::type = type
    activate()
