class PanelSwitcher
  constructor: (@host) ->
    @template = @host.firstElementChild
    @host.removeChild @template
  
  selection: (item, state) ->
    console.log item.innerHTML,state,item.classList.contains('hidden')
    if state is item.classList.contains('hidden')
      console.log "toggle"
      item.classList.toggle('hidden')
    
module.exports.client = PanelSwitcher