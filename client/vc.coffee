# Copyright (C) 2014,15 paul@marrington.net, see /GPL license
sequential = require 'Sequential'
vc_cache = {}; vcs = {}

module.exports = (container, opt_list..., ready) ->
  #container.classList.add 'invisible'
  opts = {}  # flatten opts and add DOM attributes to opts
  opts[k] = v for k, v of opt for opt in opt_list
  opts[ca.name] = ca.value for ca in container.attributes
  type = opts.vc
  base = if type[0] is '/' then '' else "/client/vc/"
  base += type

  activate = ->
    return false if not (Integrant = vc_cache[type])
    # vc loaded - activate it
    vc = new Integrant()
    vcs[type] ?= vc
    vcs[opts.name] ?= vc if opts.name
    vc.initialisers = [] # so don't need super()
    vc[k] = v for k,v of {type, base, opts}
    if container.attributes.vc
      (vc.host = container).classList.add(type)
      vc.parse_host()
    else
      vc.host = vc.view_node.cloneNode(true)
      container.appendChild vc.host
    vc.host.vc = vc

    #needing_fill = [].slice.call vc.host.getElementsByClassName("fill_parent")
    #needing_fill.push(vc.host) if vc.fill_parent ? opts.fill_parent
    #for fill in needing_fill
    #  fill.classList.remove("fill_parent")
    #  wrapper = relative_div.cloneNode()
    #  fill.parentNode.insertBefore(wrapper, fill)
    #  wrapper.appendChild(fill)

    ############
    inner_integrants = (done) ->
      inners = vc.host.getElementsByClassName('vc')
      correct_parent = (el) ->
        (vc.get_vc_for(el.parentElement) is vc)
      inners = (it for it in inners when correct_parent(it))
      do process = =>
        return done() if not inners.length # all processed
        vc_type = (el = inners.shift()).getAttribute('vc')
        module.exports el, opts[vc_type] ? {}, process
    instance_init = (done) ->
      vc.init(done)
      done() if not vc.init.length # synchronous

    component_initialisers = (done) ->
      sequential.actions vc.initialisers, done
    ############

    inner_integrants -> instance_init ->
      component_initialisers ->
        container.classList.remove 'invisible'
        ready(vc)
    return true

  return if activate()

  # come here if vc not loaded from server
  require.css "#{base}.css"
  vc_cache[type] = require base[1..-1]
  html = require.resource "#{base}.html"
  (div = empty_div.cloneNode()).innerHTML = html

  templates = div.getElementsByClassName('templates')
  if templates.length
    vc_cache[type]::templates = templates[0]
    templates[0].parentNode.removeChild templates[0]
  else
    vc_cache[type]::templates = div

  if (children = div.children).length is 1
    if (child = children[0]).classList.contains(type)
      div = child
  div.classList.add(type)
  vc_cache[type]::view_node = div

  #has_fill = (el) -> el.classList.contains('fill_parent')
  #if has_fill(div) or has_fill(vc_cache[type]::templates)
  #  vc_cache[type]::fill_parent = true

  activate()

module.exports.find = (name) -> return vcs[name]

empty_div = document.createElement("div")
#relative_div = empty_div.cloneNode()
#relative_div.classList.add('fill_parent')
