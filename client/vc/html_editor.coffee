# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class HtmlEditorView extends Integrant
  parse_host: ->
    if @child("html_editor").children.length is 0
      @wrap_inner(@host, 'html_editor')
    
  init: (ready) ->
    tabs = @get_vc_for 'tabs'
    @require 'open,tabs,toolbar,file'
    @open.editor @child('doc'), ready
   
module.exports = HtmlEditorView