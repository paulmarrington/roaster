# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class PopupMenu extends Integrant
  parse_host: -> # parse host contents before processing
    if not (modal_panel = @child("modal_panel"))
      modal_panel = @wrap_inner(@host, 'modal_panel')
    if not @child("tree_view")
      @wrap_inner(modal_panel, 'tree_view')

  init: ->
    @modal_panel = @get_vc_for "modal_panel"
    @tree_view  = @get_vc_for "tree_view"
    @tree_view.opts.one_path = @opts.one_path
    @tree_view.icon_set @opts.type if @opts.type
    @context_menu() if @opts.context_menu
    
  branch: (name)     -> @tree_view.branch name
  leaf: (name, href) -> @tree_view.leaf name, href
  up:                -> @tree_view.up()
  close_all:         -> @tree_view.close_all()
  
  show:    ->
    @close_all() if @opts.start_closed
    @modal_panel.show()
  at: (ev) ->
    @modal_panel.at(ev)
    @show()
  hide:    ->
    @modal_panel.hide()
  
  context_menu: ->
    document.addEventListener("contextmenu", ((ev) =>
      ev.preventDefault(); @at(ev)
    ), true)
   
module.exports = PopupMenu