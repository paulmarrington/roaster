# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class ModalPanel extends Integrant
  constructor: ->
    super()
    @shared_host = true
    
  init: ->
    super()
    @background = @walk 'background'
    @background.addEventListener 'click', => @hide()
    
  show: ->@background.parentNode.style.display = 'initial'
  hide: -> @background.parentNode.style.display = 'none'

module.exports = ModalPanel