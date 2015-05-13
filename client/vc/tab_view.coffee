# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

module.exports = class TabView extends Integrant
  init: ->
    super()
    @prepare(tab) for tab in @host.children
    @initialisers_for_select()
    
  add: (name, attributes = {}, ready) ->
    tab = super name, attributes, ready
    if attributes.icon
      svg = require.resource "/client/icons/#{attributes.icon}.svg"
      tab.innerHTML = "<div>#{svg}</div>"
    else
      tab.innerHTML = name
    @prepare(tab)
    return tab
  
  prepare: (tab) ->
    if 0 < tab.innerHTML.length < 32
      tab.classList.add(tab.innerHTML.replace(/\s+/, '_'))
    tab.onclick = => @select(tab)
  
  close: (name) ->
    tab = @child(name)
    tab.parentNode.removeChild(tab)