# Copyright (C) 2014 paul@marrington.net, see /GPL license
module.exports =
  # ensure resizing does not overload rendering engine - 15 fps
  resize_event: (action) ->
    id = null
    window.addEventListener 'resize', ->
      clearTimeout(id); id = setTimeout(action, 300)