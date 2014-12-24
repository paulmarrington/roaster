# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

class PanelStack extends Integrant
  find_template_parent: (template) ->
    st = super(template)
    parent = super(template)
    if (tbody = parent.getElementsByTagName('tbody')).length
      tbody = tbody[0]
    else
      tbody = document.createElement('tbody')
      parent.appendChild tbody
    return tbody
    
module.exports.client = PanelStack