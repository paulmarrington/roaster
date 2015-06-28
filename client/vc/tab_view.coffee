# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

module.exports = class TabView extends Integrant
  init: ->
    super()
    @prepare(tab) for tab in @host.children
    @initialisers_for_select()
    
  add: (name, attributes = {}, ready = ->) ->
    super name.replace(/\W+/g,'_'), attributes, (tab) =>
      tab.name = tab.innerHTML = name
      @prepare(tab)
      ready(tab)
  
  prepare: (tab) ->
    if 0 < tab.innerHTML.length < 32
      tab.classList.add(tab.innerHTML.replace(/\W+/g, '_'))
    tab.classList.add('tab')
    tab.onclick = => @select(tab)
