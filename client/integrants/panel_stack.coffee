class PanelStack
  constructor: (@host) ->
    @template = @host.firstElementChild
    @host.removeChild @template
  list: []
  add: (opts) ->
    @host.appendChild panel = @template.cloneNode(true)
    @list.push panel
    panel.addEventListener '', (event) ->
    return panel
    
module.exports.client = PanelStack