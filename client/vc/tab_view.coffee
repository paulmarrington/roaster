# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

class TabView extends Integrant
  init: ->
    super()
    @prepare(tab) for tab in @host.children
    @initialisers_for_select()
    
  add: (name, attributes, ready) ->
    tab = super name, attributes, ready
    tab.innerHTML = name
    @prepare(tab)
    return tab
  
  prepare: (tab) ->
    if tab.innerHTML.length
      tab.classList.add(tab.innerHTML.replace(/\s+/, '_'))
    tab.onclick = => @select(tab)
  
  close: (name) ->
    tab = @child(name)
    tab.parentNode.removeChild(tab)
    
module.exports.client = TabView