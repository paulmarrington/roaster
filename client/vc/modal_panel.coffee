# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class ModalPanel extends Integrant
  init: ->
    super()
    @host.classList.add @opts.type ?= 'centre'
    
    if not (@background = @child 'background')
      @wrap_inner(@host, 'container')
      @background = @template('background')
      @host.appendChild @background
    @background.addEventListener 'click', => @hide()
    @container = @child('container')
    
  show: ->
    @host.style.display = 'initial'
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
    @host.style.display = 'none'
    clearInterval @interval

module.exports = ModalPanel