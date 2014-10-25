# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

class PanelSwitcher extends Integrant
  init: ->
    @container = @child('container')
    if not @container
      @container = @templates.container.cloneNode true
      @host.appendChild @container
      while @host.children.length > 1
        @container.appendChild @host.firstChild
    @initialisers_for_select()
    
module.exports.client = PanelSwitcher