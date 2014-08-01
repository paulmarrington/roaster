# Copyright (C) 2014 paul@marrington.net, see /GPL for license
events = require 'events'; sequential = require 'Sequential'

class Integrant extends events.EventEmitter
  init: ->
    
  initialisers: []
  
  fetch_templates: () ->
    list = @host.getElementsByClassName('template')
    list = [@host.firstChild ? @host] if not list.length
    @templates = []
    for template in list
      @templates.push template
      name = template.getAttribute('name')
      @templates[name] = template if name
      template.hostess = template.parentNode
      template.parentNode.removeChild template
    
  require: (names, ready) ->
    base = @host.parent_integrant?.base ? @base
    names = names.split(',')
    
    @initialisers.push (done) =>
      sequential.list names, done, (name, next) =>
        return next() if not init = @[name].init
        init.call(@[name], @host, next)
        next() if init.length < 2 # sync
    
    sequential.list names.slice(0), ready, (name, next) =>
      require url = "#{base}/#{name}", (imports) =>
        next @[name] = new (imports[url])()
          
  style: (element, styles) ->
    element.style[k] = v for k, v of styles
      
  select: (item) ->
    item = @children[item] if typeof item is 'string'
    if @selected
      @selection(@selected, false) 
      item.picture.action?.call(@, @selected, false)
      item.picture.deselect?.call(@, @selected)
    @selection @selected = item, true
    item.picture.action?.call(@, item, true)
    item.picture.select?.call(@, item)
    
  selection: (item, state) ->
    
  walk: (path) ->
    path = path.split('/')
    here = @host
    if not path[0].length
      while here.parent_integrant
        here = here.parent_integrant.host
      path.shift()
    for point in path
      if point is '..'
        here = here.parent_integrant?.host
      else if point.length and point isnt '.'
        while not here.integrant.children[point]
          here = here.parent_integrant?.host # walk up
          return null if not here
        here = here.integrant.children[point]
    return here
  
  cargo: (cargo, processed) ->
    @children ?= {}; @list ?= []
    
    process = (done) =>
      sequential.object cargo, done, (name, next_pic) =>
        picture = cargo[name]
        picture.name ?= name
        template = @templates[picture.template ? 0]
        panel = template.cloneNode(true)
        template.hostess.appendChild panel
        panel.picture = picture
        @style panel, picture.style
        if picture.content
          panel.innerHTML = picture.content
        panel.integrant = @
        @prepare? panel
        host = (panel.getElementsByClassName(
          picture.host_class ? 'target')[0]) ?
          panel.firstChild ? panel
        host.parent_integrant = panel.parent_integrant = @
        panel.select = => @select(panel)
        panel.walk = (path) => @walk(path)
        @list.push panel
        panel.classList.add name
        @children[name] = panel
        
        return @mvc(picture, panel, next_pic) if picture.mvc

        sequential.object picture, next_pic, (key, next) =>
          action = @["cargo_#{key}"] or @[key]
          return next() if typeof action isnt 'function'
          action.call(@, picture, panel, next)
          next() if action.length < 3 # sync
          
    return process(processed) if processed
    @initialisers.push process
    
  cargo_init: (picture, panel, next) ->
    picture.init.call @, picture, panel, next
  cargo_cargo: -> # is processed by mvc: cargo entry

module.exports = Integrant