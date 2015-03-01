# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

# type: title - body
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
      flash:   age: 0.1
      clear:   age: 0
    idx = 0
    for name, type of @types
      type.priority = idx++
      type.age *= 60000
      type.name = name
    roaster.message = (msgs...) => @add msgs.join('\n - ')
    
  add: (contents) ->
    now = (new Date).getTime()
    
    try [text, type, title, body] = re.exec contents
    catch then type = 'fatal'; body = contents
    type ?= 'message'; body ?= ''
    title ?= 'Invalid Message'
    type = @types[type.toLowerCase()] ? @types.message
    
    idx = 0
    while idx < @host.children.length
      child = @host.children[idx]
      if child.innerHTML is title
        @host.removeChild child
      else
        idx++
        
    nn = @template()
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
      setTimeout (=> @host.removeChild nn), type.age
    nn.addEventListener 'click', =>
      clearTimeout nn.timer
      @host.removeChild nn
    
    if @host.children.length
      @host.insertBefore nn, @host.firstChild
    else
      @host.appendChild nn
    return nn
  
module.exports = Messages