class PanelStack
  constructor: (host) ->
    @host = host.firstElementChild.firstElementChild # tbody
    @template = @host.firstElementChild # tr
    @host.removeChild @template
    
module.exports.client = PanelStack