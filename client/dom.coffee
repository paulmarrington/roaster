# ensure resizing does not overload rendering engine - 15 fps
module.exports =
  resize_event: (action) ->
    id = null
    window.addEventListener 'resize', ->
      clearTimeout(id); id = setTimeout(action, 300)