# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

class PanelSwitcher extends Integrant
  init: ->
#     if not @child('container')
#       @host.appendChild @container = @template('container')
#       while @host.children.length > 1
#         @container.appendChild @host.firstChild
    @initialisers_for_select()
    
module.exports.client = PanelSwitcher