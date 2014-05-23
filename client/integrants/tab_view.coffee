class TabView
  constructor: (host, mvc) ->
    @host = host.firstElementChild # div
    @template = @host.getElementsByClassName('tab_view')
    @host.removeChild @template
    
  prepare: (tab) ->
    tab.onclick -> tab.opts.action(tab)
    
module.exports.client = TabView