# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'client/Integrant'

class TabView extends Integrant
  init: ->
    @default_message = ''
    @messages = @host.getElementsByClassName('messages')[0]
    
  message: (msg) ->
    if not msg.length
      return if @messages.innerHTML[0] is '<'
      message = @default_message
    @messages.innerHTML = msg
    
  error: (msg) -> @message "<b>"+msg+"</b>"
    
  prepare: (tab) ->
    tab.onclick = =>
      for other in @list
        other.classList.remove 'tab_view_selected'
      tab.classList.add 'tab_view_selected'
      tab.integrant.select(tab)
    
module.exports.client = TabView