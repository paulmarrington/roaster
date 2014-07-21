# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'client/Integrant'

picture =
  mvc: "panel_stack", require: 'tabs,toolbar,open', cargo:
    tabs: -> @tabs.picture
    doc:
      style: height: '100%'
      init:  (panel, picture, done) ->
        require.packages 'ckeditor4', =>
          @open.editor panel, picture, (cke) =>
            @ckeditor = cke
            body.tabs.inner.select 'Font'
            done()

class HtmlEditorView extends Integrant
  init: (done) -> @append picture, done 
   
module.exports = HtmlEditorView