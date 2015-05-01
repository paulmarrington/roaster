# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

module.exports = class TabbedPanels extends Integrant
  parse_host: -> @html_initialisers()
    
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
      tab.panel = @child(tab.panel, @panels)
    return tab.panel
    
  add: (name, attributes, ready) ->
    tab = @tabs.add name, attributes.tab ? attributes, ready
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