# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class PopupMenu extends Integrant
  parse_host: -> # parse host contents before processing
    if not (modal_panel = @walk("modal_panel"))
      modal_panel = @wrap(@host, 'modal_panel')
    if not @walk("tree_view")
      @wrap(modal_panel, 'tree_view')

  init: ->
    @modal_panel = @get_vc_for "modal_panel"
    @tree_view  = @get_vc_for "tree_view"
    @tree_view.icon_set @opts.type if @opts.type
    @context_menu() if @opts.context_menu
    
  branch: (name)     -> @tree_view.branch name
  leaf: (name, href) -> @tree_view.leaf name, href
  up:                -> @tree_view.up()
  
  show:    -> @modal_panel.show()
  hide:    -> @modal_panel.hide()
  at: (ev) -> @modal_panel.at(ev)
  
  context_menu: ->
    document.addEventListener("contextmenu", ((ev) =>
      ev.preventDefault(); @modal_panel.at(ev)
    ), true)
   
module.exports = PopupMenu