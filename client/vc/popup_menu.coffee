# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class PopupMenu extends Integrant
  init: ->
    @modal = @get_vc_for "modal_panel"
    @tree  = @get_vc_for "tree_view"
    
  branch: (name)     -> @tree.branch name
  leaf: (name, href) -> @tree.leaf name, href
  up:                -> @tree.up()
  
  show:    -> @modal.show()
  hide:    -> @modal.hide()
  at: (ev) -> @modal.at(ev)
   
module.exports = PopupMenu