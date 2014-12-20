# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

class TabView extends Integrant
  init: -> @initialisers_for_select()
    
  add: (name, attributes, ready) ->
    tab = super name, attributes, ready
    tab.innerHTML = name
    return tab
  
  close: (name) ->
    tab = @walk(name)
    tab.parentNode.removeChild(tab)
    
  prepare: (tab) ->
    if tab.innerHTML.length
      tab.classList.add(tab.innerHTML.replace(/\s+/, '_'))
    tab.onclick = => @select(tab)
      
module.exports.client = TabView