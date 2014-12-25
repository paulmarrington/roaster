# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

icon_path = "/client/icons"

class TreeView extends Integrant
  init: ->
    @current = @host
    if not @using_html_view
      for li in @host.getElementsByTagName('li')
        if li.getElementsByTagName('ol').length
          @wrap li, 'label'
        else
          li.classList.add 'leaf'
    @icon_set 'file'
    
  branch: (name) ->
    child = @add name, template: 'branch', host: @current, ->
    (title = @child('title', child)).innerHTML = name
    checkbox = @child('checkbox', child)
    checkbox.addEventListener "change", (ev) ->
      if checkbox.checked
        title.classList.add 'open'
      else
        title.classList.remove 'open'
    return @current = @child('children', child)
    
  leaf: (name, href) ->
    leaf = @add name, template: 'leaf', host: @current, ->
    leaf.innerHTML = name
    leaf.setAttribute 'href', href ? ''
    return leaf
      
  up: ->
    return false if @current is @host
    while @current = @current.parentNode
      return true if @current.nodeName.toLowerCase() is 'ol'
    return false
  
  # file, menu
  icon_set: (name) ->
    @host.classList.remove @last_icon_set
    @host.classList.add @last_icon_set = name
   
module.exports = TreeView