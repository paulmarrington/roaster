TabbedPanels = require 'vc/tabbed_panels'

class Drawers extends TabbedPanels
  constructor: ->
    super()
    @shared_host = true
  init: ->
    super()
    table = @walk('drawers')
    
    if @opts.side isnt 'right'
      @tabs.host.classList.add 'left'
    else
      table.style.right = '0px'
      @tabs.host.classList.add 'right'
      tr = @tabs.host.parentNode.parentNode
      td_tabs = @tabs.host.parentNode
      td_panels = @panels.host
      tr.insertBefore td_tabs, td_panels
      
    show = => @show()
    
    @tabs.on 'selected', (tab) =>
      @show()
      tab.addEventListener 'mouseenter', show
      @emit 'selected', @selected = @tab_panel tab
      
    @tabs.on 'deselected', (tab) =>
      tab.removeEventListener 'mouseenter', show
      @emit 'deselected', @tab_panel tab
      
    table.addEventListener 'mouseleave', => @hide()
      
  show: ->
    @panels.host.style.removeProperty "max-width"
    @panels.host.style.padding = '6px'
    
  hide: ->
    @panels.host.style["max-width"] = '0px'
    @panels.host.style.padding = '0px'
  
module.exports.client = Drawers