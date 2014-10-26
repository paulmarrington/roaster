# Copyright (C) 2014 paul@marrington.net, see /GPL for license
events = require 'events'; sequential = require 'Sequential'
vc_builder = require 'vc'

class Integrant extends events.EventEmitter
  constructor: ->
    @initialisers = []
    
  get_vc_for: (el) -> # find the vc owning this element
    if typeof el is 'string'
      return null if not (el = @walk(el))
    host = el
    host = host.parentNode while host and not host.vc
    return el.vc ?= host?.vc
    
  shared_events: new events.EventEmitter
    
  init: ->
  prepare: (item) ->
    
  require: (names, ready) ->
    base = @base
    base = base[0..-2] if base[-1..-1] is '/'
    names = names.split(',')
    
    requires = (done) =>
      sequential.list names.slice(0), done, (name, next) =>
        require url = "#{base}/#{name}", (imports) =>
          next @[name] = new (imports[url])()
        
    inits = (done) => do next = =>
      return done() if not names.length
      rq = @[names.shift()]
      rq.vc = @
      return next() if not init = rq.init
      init.call(rq, next)
      next() if init.length < 2 # sync
    
    requires -> inits -> ready()
          
  style: (element, styles) ->
    element.style[k] = v for k, v of styles
      
  select: (item) ->
    item = @walk(item) if typeof item is 'string'
    vc = @get_vc_for item
    if vc.selected isnt item
      vc.emit 'deselected', vc.selected if vc.selected
      vc.emit 'selected', vc.selected = item
    
  # walk a class path and return a list that matches leaf
  list: (path, here = @host) ->
    path = path.split('/')
    # start with /path - go to most parent vc
    if not path[0].length # /path
      there = here
      while there = there.parentNode
        here = there = there.vc.host if there.vc
      path.shift()
    # now walk the path (... copies path)
    leaf = path.pop()
    do lister = (path) ->
      return true if not path.length
      if (point = path.shift()) is '..'
        # go back to the parent with an vc
        while here = here.parentNode
          break if here.vc
        here = here.vc.host
        return lister(path)
      else if point.length and point isnt '.'
        # recusively investigate classes
        # can be a space separated list of classes (and)
        found = here.getElementsByClassName(point)
        return if not found.length # dead end
        for here in found # try each possibility
          return true if lister(path.slice(0))
        return false
    # copy from dom to array
    return (e for e in here.getElementsByClassName(leaf))
  # walk to a single known leaf given path of classes
  walk: (path, here) -> return @list(path, here)?[0]
  # more restrictive - find immediate child with class
  child: (cls) ->
    child = @host.firstElementChild
    while child and not child.classList.contains(cls)
      child = child.nextElementSibling
    return child
  
  initialisers_for_select: ->
    @on 'selected', (panel) ->
      panel.classList.add 'active'
    @on 'deselected', (panel) ->
      panel.classList.remove 'active'
    @initialisers.push => @reset_selection()
  
  reset_selection: ->
    @selected = null
    for el in @list('vc active')
      @select el if @get_vc_for(el) is @
        
  # add a new child element from template
  add: (name, attributes, ready) ->
    template = @templates[attributes.template ? 0]
    child = template.cloneNode true
    child.setAttribute(k, v) for k, v of attributes
    template.hostess.appendChild child
    @prepare child
    ready ?= ->
    if attributes.vc
      vc_builder child, attributes, ready
    else ready()
    child.classList.add name
    return @[name] = @walk('container', child) ? child
    
module.exports = Integrant