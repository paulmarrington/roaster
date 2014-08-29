# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'Integrant'

class TabView extends Integrant
  init: ->
    @default_message = '&nbsp;'
    @messages = @host.getElementsByClassName('messages')[0]
    
  message: (msg) ->
    if not msg.length
      return if @messages?.innerHTML[0] is '<'
      msg = @default_message
    @messages?.innerHTML = msg
    
  error: (msg) -> @message "<b>"+msg+"</b>"
  
  selection: (tab, state) ->
    if state
      tab.classList.add 'tab_view_selected'
    else
      tab.classList.remove 'tab_view_selected'
    
  prepare: (tab) ->
    if not tab.picture.content
      tab.innerHTML = tab.picture.name
    tab.onclick = => tab.integrant.select(tab)
    tab.onclick() if tab.picture.selected
    
module.exports.client = TabView