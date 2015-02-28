# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

icon_path = "/client/icons"

class TreeView extends Integrant
  init: ->
    @current = @host
    for li in @host.getElementsByTagName('li')
      if ol = li.getElementsByTagName('ol')[0]
        ol.classList.add('children')
        ol.parentNode.removeChild ol
        li.removeChild span = @wrap_inner(li, 'title')
        li.appendChild label = @template 'label'
        label.appendChild ol
        label.insertBefore span, label.firstChild
        @activate_branch li
      else
        li.classList.add 'leaf'
    @icon_set 'file'
    
  activate_branch: (branch) ->
    checkbox = @child('checkbox', branch)
    title = @child('title', branch)
    checkbox.addEventListener "change", (ev) ->
      if checkbox.checked
        title.classList.add 'open'
      else
        title.classList.remove 'open'
    
  branch: (name) ->
    child = @add name, template: 'branch', host: @current, ->
    @child('title', child).innerHTML = name
    @activate_branch child
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