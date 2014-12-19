# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class PopupMenu extends Integrant
  init: ->
    @tree = @walk("tree_view")
    
  branch: (name) -> @tree.branch name
  leaf: (name, href) -> @tree.leaf name, href
  up: -> @tree.up()
   
module.exports = PopupMenu