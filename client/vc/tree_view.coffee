# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class TreeView extends Integrant
  init: ->
    @current = @root = @walk("tree_view")
    if not @using_html_view
      for li in @root.getElementsByTagName('li')
        if li.getElementsByTagName('ol').length
          @wrap li, 'label'
        else
          li.classList.add 'file', 'leaf'
    
  branch: (name) ->
    child = @add name, template: 'branch', host: @current, ->
    @walk('title', child).innerHTML = name
    return @current = @walk('branch', child)
    
  leaf: (name, href) ->
    leaf = @add name, template: 'leaf', host: @current, ->
    leaf.innerHTML = name
    leaf.setAttribute 'href', href ? ''
    return leaf
      
  up: ->
    return false if @current is @root
    while @current = @current.parentNode
      return true if @current.nodeName.toLowerCase() is 'ol'
    return false
   
module.exports = TreeView