# Copyright (C) 2014/15 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

default_specs =
  location: 0, menubar: 0, status: 0, titlebar: 0, toolbar: 0

set_specs = (list...) ->
  res = []
  for spec in list when spec
    if typeof spec is 'string'
      res.push spec
    else
      res.push "#{k}=#{v}" for k, v of spec
  return res.join ','

default_size_specs = () ->
  width = 600; left = 0; window_id++
  if width > window.screen.availWidth
    width = window.screen.availWidth
  # | el ww er |
  el = window.screenLeft
  ww = window.outerWidth
  er = window.screen.availWidth - el - ww
  if width < er
    left = el + ww
  else  if el < er
    left = window.screen.availWidth - width
  else if width <= el
    left = el - width

  top = window.screenTop
  if (height = window.screen.availHeight) > 1000
    height /= 2
    top += height if not (window_id % 2)

  return {left,top,width,height}

window_id = 0

saved_specs = (name) ->
  specs = localStorage.getItem "Window:#{name}"
  return specs ? default_size_specs()

store_specs = (name, win) ->
  localStorage.setItem "Window:#{name}",
  "left=#{win.screenLeft},top=#{win.screenTop},"+
  "width=#{win.outerWidth},height=#{win.innerHeight}"

module.exports = class WindowManager extends Integrant
  parse_host: -> @html_initialisers()

  init: ->
    @tabs = @get_vc_for 'tabs'
    @tabs.on 'selected', (tab) =>
      tab.window.focus()
      @emit 'selected', @selected = tab.panel
    @tabs.on 'deselected', (tab) =>
      @emit 'deselected', tab.panel

    @tabs.reset_selection()

  add: (name, attributes, ready) ->
    tab = @tabs.add name, attributes.tab, ready
    specs = set_specs(
      default_specs, saved_specs(name), attributes.specs)
    tab.window = win = window.open "", name, specs
    tab.panel  = panel = win.document.body
    @setAttributes panel, attributes.panel if attributes.panel
    window.addEventListener 'beforeunload', -> win.close()
    win.addEventListener 'beforeunload', =>
      store_specs(name, win)
      @tabs.close name
    tab.panel.tab = tab
    return panel
  
  close: (name) -> @tabs.child(name).window.close()
      
  select: (tab) -> @tabs.select tab