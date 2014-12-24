# Copyright (C) 2014 paul@marrington.net, see /GPL for license
events = require 'events'
vc_builder = require 'vc'

class Integrant extends events.EventEmitter
  constructor: -> @initialisers = []
    
  parse_host: -> # parse host contents before processing
    
  get_vc_for: (el) -> # find the vc owning this element
    if typeof el is 'string'
      return @ if el is @type
      return null if not (el = @child(el))
    host = el
    host = host.parentNode while host and not host.vc
    return el.vc ?= host?.vc
    
  shared_events: new events.EventEmitter
    
  init: ->
    
  require: (names) ->
    base = @base
    base = base[0..-2] if base[-1..-1] is '/'
    for name in names.split(',')
      @[name] = new (require("#{base}/#{name}"))()
      @[name].vc = @
    
  style: (element, styles) ->
    element.style[k] = v for k, v of styles
      
  select: (item) ->
    item = @child(item) if typeof item is 'string'
    vc = @get_vc_for item
    if vc.selected isnt item
      vc.emit 'deselected', vc.selected if vc.selected
      vc.emit 'selected', vc.selected = item
    return item
    
  list: (cls, here = @host) ->
    list = (e for e in here.getElementsByClassName(cls))
    list.unshift(here) if here.classList.contains(cls)
    return list
  
  child: (cls, here) -> return @list(cls, here)?[0] ? null
  
  initialisers_for_select: ->
    @on 'selected', (panel) ->
      panel.classList.add 'active'
    @on 'deselected', (panel) ->
      panel.classList.remove 'active'
    @initialisers.push => @reset_selection()
  
  reset_selection: ->
    @selected = null
    for el in @list('active')
      @select el if @get_vc_for(el) is @
        
  setAttributes: (node, attributes) ->
    for k, v of attributes
      node.setAttribute(k, v) if typeof v isnt 'object'
        
  add: (classes, attributes, ready = ->) ->
    attributes ?= {}
    child = @attach_template(attributes.template)
    child.classList.add classes.split(' ')...
    @setAttributes child, attributes
    child.contents = @child('container', child) ? child
    if attributes.vc
      vc_builder child, attributes, -> ready(child)
    else
      ready(child)
    return child
  
  template: (name = @type) ->
    template = @child(name, @templates)
    if not template
      if @templates.children.length
        template = @templates.children[0] 
      else
        template = @templates
    return template.cloneNode(true)
  
  attach_template: (name) ->
    child = @template(name)
    template = child.getAttribute('template')
    parent = if template is @type then @host else
      if (parent = @child(template)) then parent else @host
    parent.appendChild(child)
    return child
  
  # @wrap_inner(n, t) means n(b) becomes n(t(b)) - returns t
  wrap_inner: (node, template_name) ->
    wrapper = @template(template_name)
    while node.childNodes.length
      wrapper.appendChild node.firstChild
    node.appendChild wrapper
    return wrapper

module.exports = Integrant