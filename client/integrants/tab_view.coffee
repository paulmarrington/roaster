class TabView
  message: (msg) ->
    if not msg.length
      return if @messages.innerHTML[0] is '<'
      message = @default_message
    @messages.innerHTML = msg
    
  error: (msg) -> @message "<b>"+msg+"</b>"
  
  constructor: (host, mvc) ->
    @default_message = ''
    @messages = host.getElementsByClassName('messages')[0]
    @template = host.getElementsByClassName('tab_view')[0]
    @host = @template.parentNode
    @host.removeChild @template
    
  prepare: (tab) ->
    tab.onclick = =>
      for other in @list
        other.classList.remove 'tab_view_selected'
      tab.classList.add 'tab_view_selected'
      tab.parent_panel.select(tab)
    
module.exports.client = TabView