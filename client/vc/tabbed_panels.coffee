# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

class TabbedPanels extends Integrant
  init: ->
    @tabs = @get_vc_for 'tabs'
    @panels = @get_vc_for 'panels'

    @tabs.on 'selected', (tab) =>
      @panels.select panel = @tab_panel tab
      @emit 'selected', @selected = panel
    @tabs.on 'deselected', (tab) =>
      @emit 'deselected', @tab_panel tab
    @tabs.reset_selection()
    
  tab_panel: (tab) ->
    tab.panel ?= tab.getAttribute("panel")
    if typeof tab.panel is 'string'
      tab.panel = @walk("panels/#{tab.panel}")
    return tab.panel
    
  add: (name, attributes, ready) ->
    tab = @tabs.add name, attributes.tab, ready
    panel = @panels.add name,
      attributes.panel ? attributes, ready
    tab.panel = panel
    panel.tab = tab
    return panel
      
  select: (tab) ->
    panel = @tab_panel(tab = @tabs.select tab)
    if not panel.clientHeight # a webkit redisplay bug
      td = panel.parentNode.parentNode
      [height,td.style.height] = [td.style.height, '0']
      process.nextTick -> td.style.height = height
      
module.exports.client = TabbedPanels