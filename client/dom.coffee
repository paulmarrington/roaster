# Copyright (C) 2014 paul@marrington.net, see /GPL license
module.exports = dom =
  # walk up higher level elements (same or ancestor level)
  precedent: (el, test) ->
    while el
      if above = el.previousSibling or el.parentNode
        return above if test(above)
      el = above
    return null

  # ensure resizing does not overload rendering engine - 15 fps
  resize_event: (action) ->
    return dom.throttled_event 'resize', window, action, 300
    
  mousemove_event: (action) ->
    return dom.throttled_event 'mousemove', document, action, 300
    
  mouse_capture: (handle, capture) ->
    handle.addEventListener "mousedown", (evt) ->
      capture.down?(evt)
      @in_move = false

      document.addEventListener 'selectstart', ms = (evt) ->
        evt.preventDefault() # so we don't get any highlighting

      document.addEventListener 'mousemove', mm = (evt) =>
        return if @in_move
        @in_move = true
        capture.move?(evt)
        @in_move = false

      document.addEventListener "mouseup", mu = (evt) ->
        mm evt # for anything in the throttled delay time
        document.removeEventListener "selectstart", ms
        document.removeEventListener "mouseup", mu
        document.removeEventListener "mousemove", mm
        capture.up?(evt)
        
  throttled_event: (event, element, action, delay = 300) ->
    id = null
    return element.addEventListener event, (args...) ->
      clearTimeout(id)
      id = setTimeout (-> action?.apply(element, args)), delay
