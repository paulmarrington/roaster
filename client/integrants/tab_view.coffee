class TabView
  constructor: (host, mvc) ->
    @host = host.firstElementChild # div
    @template = @host.getElementsByClassName('tab_view')
    @panel_tpl = @host.getElementsByClassName('tab_view_panel')
    @host.removeChild @template
    mvc 'panel_stack', host, (err, body) ->
      body.add tabs: {}, contents: style: height: '100%'
      body.tabs.appendChild(@tab_view)
  prepare: (tab) ->
    if tab.opts.panel or not tab.opts.action
      
module.exports.client = TabView