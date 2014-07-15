# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'client/Integrant'

class PanelSwitcher extends Integrant
  selection: (item, state) ->
    if state is item.classList.contains('hidden')
      item.classList.toggle('hidden')
    
module.exports.client = PanelSwitcher