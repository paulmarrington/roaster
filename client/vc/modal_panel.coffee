# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class ModalPanel extends Integrant
  init: ->
    super()
    #@host.classList.add @opts.type ?= 'centre'
    
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
    console.log 1,x,y
    do move_to = =>
      if (x + @container.offsetWidth) < window.innerWidth
        @container.style.left = x+"px"
        @container.style.right = null
      else
        @container.style.left = null
        @container.style.right = "8px"
      if (y + @container.offsetHeight) < window.innerHeight
        @container.style.top = y+"px"
        @container.style.bottom = null
      else
        @container.style.top = null
        @container.style.bottom = "8px"
    @interval = setInterval move_to, 250
  
  hide: ->
    return @destroy() if not @opts.keep
    @host.style.display = 'none'
    clearInterval @interval
    
  destroy: ->
    @host.parentNode.removeChild @host
    
# shortcut so that modal panels can be created easily
vc = require 'vc'
roaster.modal = global.modal = (filler) ->
  vc document.body, vc: 'modal_panel', (modal) ->
    filler(modal.container)
    modal.show()

module.exports = ModalPanel
