# Copyright (C) 2015 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'
dom = require 'dom'

min_width = (td) ->
  if mw = td.style["min-width"]
    mw = +mw.match(/\d*/)[0]
  mw = td.offsetWidth if not mw
  return mw

module.exports = class PanelShelf extends Integrant
  init: ->
    if (@overflows = @list('hide-on-overflow')).length
      @window_width = 10000
      do resizer = =>
        if window.innerWidth > @window_width #growing
          for overflow in @overflows
            overflow.style.display = 'table-cell'
        @window_width = window.innerWidth
            
        process.sleep 500, =>
          abreast_width = 0
          for td in @overflows[0].parentNode.children
            abreast_width += min_width(td)
            
          process.nextTick =>
            idx = @overflows.length
            while abreast_width > window.innerWidth
              break if idx is 0
              overflow = @overflows[--idx]
              abreast_width -= overflow.offsetWidth
              overflow.style.display = 'none'
        
      dom.resize_event -> resizer()
