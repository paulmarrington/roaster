# Copyright (C) 2014 paul@marrington.net, see /GPL for license
events = require 'events'

class Integrant extends events.EventEmitter
  init: (ready) -> ready()
  
  fetch_templates: () ->
    list = @host.getElementsByClassName('template')
    @templates = []
    for template in list
      @templates.push template
      name = template.getAttribute('name')
      @templates[name] = template if name
      template.host = template.parentNode
      template.parentNode.removeChild template 
    
  require: (module_names..., ready) ->
    names = (name \
      for name in sets.split(',') for sets in module_names)
    names = names.reduce (a, b) -> a.concat b
    do loader = =>
      return ready() if names.length is 0
      name = names.shift()
      require url = "client/integrants/#{@name}/#{name}", (the) =>
        @[name] = new (the[url])()
        if @[name].init
          @[name].init(@, loader)
        else
          loader()
          
  style: (element, styles) ->
    element.style[k] = v for k, v of styles
      
  append: (opts = {}) ->
    @list ?= []
    template = @templates[opts.template ? 0]
    template.host.appendChild panel = template.cloneNode(true)
    @list.push panel
    panel.opts = opts
    @style panel, opts.style
    panel.innerHTML = opts.content if opts.content
    panel.integrant = @
    @prepare? panel
    if opts.integrant
      if opts.host_class
        host = panel.getElementsByClassName(opts.host_class)[0]
      else
        host = panel.firstChild ? panel
      @mvc opts.name, opts.integrant, host, opts, (err, inner) ->
        panel.inner = inner
        inner.add opts.add if opts.add
    return panel
  
  add: (items) ->
    for name, opts of items
      opts.name ?= name
      opts.action ?= @opts.action
      opts.content = opts.name if @opts.named_content
      @[name] = @append(opts)
      
  select: (tab) ->
    tab = @[tab] if typeof tab is 'string'
    tab.opts.action.call @, @selected, false if @selected
    tab.opts.action.call @, @selected = tab, true
    
module.exports = Integrant