# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

re = /^(?:\s*(.+?)\s*:)?\s*(.+?)\s*(?:-\s*(.*)\s*)?$/

class Messages extends Integrant
  init: ->
    super()
    @types =
      fatal:   age: 0
      error:   age: 0
      alert:   age: 48*60
      pass:    age: 60
      message: age: 60
    idx = 0
    for name, type of @types
      type.priority = idx++
      type.age *= 60000
      type.name = name
    @container = @templates[0].hostess
    
  add: (contents) ->
    now = (new Date).getTime()
    
    try [text, type, title, body] = re.exec contents
    catch
      type = 'fatal'; body = contents
    type ?= 'message'; body ?= ''
    title ?= 'Invalid Message'
    type = @types[type.toLowerCase()] ? @types.message
    
    idx = 0
    while idx < @container.children.length
      child = @container.children[idx]
      if child.innerHTML is title
        @container.removeChild child
      else
        idx++
        
    nn = @templates[0].cloneNode(true)
    nn.timestamp = now; nn.body = body
    nn.type = type; nn.innerHTML = title
    nn.classList.add type.name
    nn.addEventListener 'mouseover', ->
      elapsed = ((new Date).getTime() - nn.timestamp)
      elapsed = Math.floor elapsed / 60000
      title = "#{elapsed} minutes ago"
      title = "#{nn.body} (#{title})" if nn.body
      nn.setAttribute 'title', title
    if type.age then nn.timer =
      setTimeout (=> @container.removeChild nn), type.age
    nn.addEventListener 'click', =>
      clearTimeout nn.timer
      @container.removeChild nn
    
    if @container.children.length
      @container.insertBefore nn, @container.firstChild
    else
      @container.appendChild nn
    return nn
  
module.exports = Messages