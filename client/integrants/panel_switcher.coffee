class PanelSwitcher
  constructor: (@host) ->
    @template = @host.firstElementChild
    @host.removeChild @template
  
  selection: (item, state) ->
    if state is item.classList.contains('hidden')
      item.classList.toggle('hidden')
    
module.exports.client = PanelSwitcher