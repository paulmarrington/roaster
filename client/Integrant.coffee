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
      require url = "#{@type}/#{name}", (the) =>
        @[name] = new (the[url])()
        if @[name].init
          @[name].init(@, loader)
        else
          loader()
          
  style: (element, styles) ->
    element.style[k] = v for k, v of styles
      
  append: (picture, done) ->
    @list ?= []
    template = @templates[picture.template ? 0]
    template.host.appendChild panel = template.cloneNode(true)
    @list.push panel
    panel.picture = picture
    @style panel, picture.style
    panel.innerHTML = picture.content if picture.content
    panel.integrant = @
    @prepare? panel
    return done(null, panel) if not picture.mvc
    if picture.host_class
      host = panel.getElementsByClassName(picture.host_class)[0]
    else
      host = panel.firstChild ? panel
    @mvc picture, host, done
      
  select: (item) ->
    item = @children[item] if typeof item is 'string'
    @selection @selected, false if @selected
    item.picture.action?.call @, @selected, false if @selected
    @selection @selected = item, true
    item.picture.action?.call @, item, true
    
  selection: (item, state) ->
    
  walk: (path) ->
    path = path.split('/')
    here = @host
    if not path[0].length
      here = here.parent_integrant while here.parent_integrant
      path.shift()
    for point in path
      if point is '..'
        here = here.parent_integrant
      else
        here = here.integrant.children[point]
    return here
    
module.exports = Integrant