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
    branch.checkbox = @child('checkbox', branch)
    branch.title_span = @child('title', branch)
    branch.checkbox.addEventListener "change", =>
      if branch.checkbox.checked
        @open(branch)
      else
        @close(branch)
            
  open: (branch) ->
    branch.title_span.classList.add 'open'
    branch.checkbox.checked = true
    if @opts.one_path
      for li in branch.parentNode.getElementsByTagName('li')
        @close(li) if li.title_span and li isnt branch
          
  close: (branch) ->
    branch.title_span.classList.remove 'open'
    branch.checkbox.checked = false
    
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
  
  close_all: ->
    for checkbox in @list('checkbox')
      checkbox.checked = false
    for title in @list('title')
      title.classList.remove 'open'
  
  # file, menu
  icon_set: (name) ->
    @host.classList.remove @last_icon_set
    @host.classList.add @last_icon_set = name
   
module.exports = TreeView