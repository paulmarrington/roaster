# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class HtmlEditorView extends Integrant
  init: (ready) ->
    tabs = @get_vc_for 'tabs'
    @require 'open,tabs,toolbar,file'
    @open.editor @child('doc'), ready
   
module.exports = HtmlEditorView