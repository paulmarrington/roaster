# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class ModalPanel extends Integrant
  constructor: ->
    super()
    @shared_host = true
    
  init: ->
    super()
    @panel = @walk('modal_panel')
    @panel.classList.add @opts.type ?= 'centre'
    
    if not (@background = @walk 'background')
      @background = @templates.background.cloneNode(true)
      @wrap(@panel, 'contents')
      @panel.appendChild @background
    @background.addEventListener 'click', => @hide()
    @container = @walk('container')
    
  show: ->
    @panel.style.display = 'initial'
    clearInterval @interval
  
  # panel.show().at(screenX: 100, screenY: 250)
  at: (ev) ->
    @show()
    x = ev.clientX; y = ev.clientY
    do move_to = =>
      if (x + @container.offsetWidth) < window.innerWidth
        @container.style.left = x
        @container.style.right = null
      else
        @container.style.left = null
        @container.style.right = 8
      if (y + @container.offsetHeight) < window.innerHeight
        @container.style.top = y
      else
        @container.style.top = 8
    @interval = setInterval move_to, 250
  
  hide: ->
    @panel.style.display = 'none'
    clearInterval @interval

module.exports = ModalPanel