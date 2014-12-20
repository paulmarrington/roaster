# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class PopupMenu extends Integrant
  init: ->
    @modal = @get_vc_for "modal_panel"
    @tree  = @get_vc_for "tree_view"
    @tree.icon_set @opts.type if @opts.type
    @context_menu() if @opts.context_menu
    
  branch: (name)     -> @tree.branch name
  leaf: (name, href) -> @tree.leaf name, href
  up:                -> @tree.up()
  
  show:    -> @modal.show()
  hide:    -> @modal.hide()
  at: (ev) -> @modal.at(ev)
  
  context_menu: ->
    document.addEventListener("contextmenu", ((ev) =>
      ev.preventDefault(); @modal.at(ev)
    ), true)
   
module.exports = PopupMenu