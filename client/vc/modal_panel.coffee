# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class ModalPanel extends Integrant
  constructor: ->
    super()
    @shared_host = true
    
  init: ->
    super()
    if not (@background = @walk 'background')
      @background = @templates.background.cloneNode(true)
      mp = @walk('modal_panel')
      @wrap(mp, 'contents').appendChild @background
    @background.addEventListener 'click', => @hide()
    
  show: ->@background.parentNode.style.display = 'initial'
  hide: -> @background.parentNode.style.display = 'none'

module.exports = ModalPanel