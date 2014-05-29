class TabView
  constructor: (host, mvc) ->
    @host = host.firstElementChild # div
    @template = @host.getElementsByClassName('tab_view')[0]
    @template.parentNode.removeChild @template
    
  prepare: (tab) ->
    tab.onclick = =>
      for other in @list
        other.classList.remove 'tab_view_selected'
      tab.classList.add 'tab_view_selected'
      tab.parent_panel.select(tab)
    
module.exports.client = TabView