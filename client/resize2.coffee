# Copyright (C) 2015 paul@marrington.net, see /GPL for license

parse = (element) ->
  split = /^(\d+)(.*)$/.exec element.style.height
  if split
    [style, value, type] = split
    value = +value
  else if value = +element.style.height
    type = 'px'
  else
    [value, type] = [50, '%']
  if type is '%'
    update = (moved, percent) ->
      @element.style.height = "#{value + percent}%"
  else
    update = (moved, percent) ->
      @element.style.height = "#{value + moved}px"
  return {element, type, update}

class Resize2
  constructor: (handle, upper, lower, on_completion = ->) ->
    @height = upper.clientHeight + lower.clientHeight
    handle.addEventListener "mousedown", (evt) =>
      @upper = parse(upper)
      @lower = parse(lower)
      @from = evt.clientY
      @in_move = false

      document.addEventListener 'selectstart', ms = (evt) =>
        evt.preventDefault()

      document.addEventListener "mousemove", mm = (evt) =>
        return if @in_move
        @in_move = true
        moved = evt.clientY - @from
        percent = (moved * 100) // @height
        @upper.update moved, percent
        @lower.update -moved, -percent
        @in_move = false

        document.addEventListener "mouseup", mu = (evt) =>
          document.removeEventListener "selectstart", ms
          document.removeEventListener "mouseup", mu
          document.removeEventListener "mousemove", mm
          on_completion(
            @upper.element.style.height
            @lower.element.style.height)

module.exports  = (opts, saver) ->
  new Resize2(opts.handle, opts.upper, opts.lower, saver)