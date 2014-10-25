# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

class TabbedPanels extends Integrant
  init: ->
    @tabs = @get_vc_for 'tabs'
    @panels = @get_vc_for 'panels'

    @tabs.on 'selected', (tab) =>
      @panels.select tab.getAttribute "panel"
      @emit 'selected', tab
    @tabs.on 'deselected', (tab) =>
      @emit 'deselected', tab
    @tabs.reset_selection()
      
  select: (tab) -> @tabs.select tab
  message: (msg) -> @tabs.message msg
  error: (msg) -> @message "<b>"+msg+"</b>"
      
module.exports.client = TabbedPanels