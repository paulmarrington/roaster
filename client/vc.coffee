# Copyright (C) 2014,15 paul@marrington.net, see /GPL license
sequential = require 'Sequential'
vc_cache = {}

module.exports = (container, opt_list..., ready) ->
  opts = {}  # flatten opts and add DOM attributes to opts
  opts[k] = v for k, v of opt for opt in opt_list
  opts[ca.name] = ca.value for ca in container.attributes
  type = opts.vc
  base = if type[0] is '/' then '' else "/client/vc/"

  activate = ->
    return false if not (Integrant = vc_cache[type])
    # vc loaded - activate it
    vc = new Integrant()
    vc[k] = v for k,v of {type, base, opts}
    if container.attributes.vc
      (vc.host = container).classList.add(type)
      vc.parse_host()
    else
      vc.host = vc.view_node.cloneNode(true)
      container.appendChild vc.host
    vc.host.vc = vc
      
    ############
    inner_integrants = (done) ->
      vcs = (it for it in vc.host.getElementsByClassName('vc'))
      do process = =>
        return done() if not vcs.length # all processed
        parent = vc.get_vc_for(el = vcs.shift())
        return process() if parent isnt vc # sub-sub-vc
        vc_type = el.getAttribute('vc')
        module.exports el, opts[vc_type] ? {}, process
      
    instance_init = (done) ->
      vc.init(done)
      done() if not vc.init.length # synchronous
        
    component_initialisers = (done) ->
      sequential.actions vc.initialisers, done
    ############
      
    inner_integrants -> instance_init ->
      component_initialisers -> ready(null, vc)
    return true
  
  return if activate()
  # come here if vc not loaded from server
  base = "#{base}#{type}"
  require.css "#{base}.css"
  vc_cache[type] = require base[1..-1]
  require.static "#{base}.html", (error, html) ->
    (div = empty_div.cloneNode()).innerHTML = html
    
    templates = div.getElementsByClassName('templates')
    vc_cache[type]::templates = empty_div
    if templates.length
      vc_cache[type]::templates = templates[0]
      templates[0].parentNode.removeChild templates[0]
      
    if (children = div.children).length is 1
      if (child = children[0]).classList.contains(type)
        div = child
    div.classList.add(type)
    vc_cache[type]::view_node = div
    
    activate()
    
empty_div = document.createElement("div")