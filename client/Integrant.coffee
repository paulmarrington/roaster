# Copyright (C) 2014 paul@marrington.net, see /GPL for license
events = require 'events'; sequential = require 'Sequential'

class Integrant extends events.EventEmitter
  init: ->
  
  fetch_templates: () ->
    list = @host.getElementsByClassName('template')
    @templates = []
    for template in list
      @templates.push template
      name = template.getAttribute('name')
      @templates[name] = template if name
      template.hostess = template.parentNode
      template.parentNode.removeChild template
    
  require: (sets, ready) ->
    base = @host.parent_integrant?.base ? @base
    names = sets.split(',')
    
    load = (done) =>
      sequential.list names, ready, (name, next) =>
        require url = "#{base}/#{name}", (imports) =>
          next @[name] = new (imports[url])()
              
    initialise = (done) =>
      sequential.list names, ready, (name, next) =>
        if init = @[name].init
          init(@host, next)
          next() if init.length < 2 # sync
            
    load -> initialise -> ready()
          
  style: (element, styles) ->
    element.style[k] = v for k, v of styles
      
  append: (picture, done) ->
    @list ?= []
    template = @templates[picture.template ? 0]
    template.hostess.appendChild panel = template.cloneNode(true)
    @list.push panel
    panel.picture = picture
    @style panel, picture.style
    panel.innerHTML = picture.content if picture.content
    panel.integrant = @
    @prepare? panel
    if picture.mvc
      if picture.host_class
        host = panel.getElementsByClassName(
          picture.host_class)[0]
      else
        host = panel.firstChild ? panel
      host.parent_integrant = @
      @mvc picture, host, done
    else
      panel.parent_integrant = @
      on_processed = -> done(null, panel)
      sequential.object picture, on_processed, (key, next) =>
        action = @["cargo_#{key}"] or @[key]
        return next() if not action
        action.call(@, panel, picture, next)
        next() if action.length < 2 # sync
      
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
  
  cargo: (cargo, done) ->
    @children ?= {}
    sequential.object cargo, done, (name, next) =>
      data = cargo[name]
      data = data.call(@) if typeof data is 'function'
      @append data, (err, child) =>
        child.select = => @select(name)
        child.walk = (path) => @walk(path)
        child.classList.add name
        next @children[name] = child
        
  cargo_init: (panel, picture, done) -> picture.init(panel, done)
    
module.exports = Integrant