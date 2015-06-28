# Copyright (C) 2015 paul@marrington.net, see /GPL for license
dom = require 'dom'

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
  return {element, type, update, value}

class Resize2
  constructor: (handle, upper, lower, on_completion = ->) ->
    do get_height = => @height = upper.clientHeight + lower.clientHeight
    @upper = parse(upper)
    @lower = parse(lower)
    
    dom.mouse_capture handle,
      down: (evt) =>
        @upper = parse(upper)
        @lower = parse(lower)
        @from = evt.clientY
      move: (evt) =>
        moved = evt.clientY - @from
        percent = (moved * 100) // @height
        @upper.update moved, percent
        @lower.update -moved, -percent
        on_completion(@upper, @lower, @height)
      up: =>
        on_completion(@upper, @lower, @height)
            
    dom.resize_event =>
      old_height = @height
      get_height()
      if @upper.type != '%' and @lower.type != '%'
        change = @height - old_height
        @upper.update change
        @lower.update change
        on_completion(@upper, @lower, @height)

module.exports  = (opts, saver) ->
  new Resize2(opts.handle, opts.upper, opts.lower, saver)
