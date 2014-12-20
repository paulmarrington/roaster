# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class HtmlEditorView extends Integrant
  init: (ready) ->
    tabs = @get_vc_for 'tabs'
    roaster.message = (msg...) => tabs.message msg...
    roaster.error = (msg...) =>  tabs.error msg...
    @require 'open,tabs,toolbar,file'
    @open.editor @walk('doc'), ready
   
module.exports = HtmlEditorView