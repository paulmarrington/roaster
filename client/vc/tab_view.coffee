# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

class TabView extends Integrant
  init: ->
    @default_message = '&nbsp;'
    @messages = @host.getElementsByClassName('messages')[0]
    if not @messages
      @messages = @templates.messages.cloneNode true
      @host.appendChild @messages
    @initialisers_for_select()
    
  message: (msg) ->
    if not msg.length
      return if @messages?.innerHTML[0] is '<'
      msg = @default_message
    @messages?.innerHTML = msg
    
  error: (msg) -> @message "<b>"+msg+"</b>"
    
  prepare: (tab) ->
    tab.classList.add(tab.innerHTML.replace(/\s+/, '_'))
    tab.onclick = => @select(tab)
      
module.exports.client = TabView