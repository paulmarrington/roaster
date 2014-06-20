# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'client/Integrant'

picture =
  ed: mvc: "panel_stack", require: 'tabs,toolbar,open', cargo:
    tabs: init: (ready) ->
      ready @tabs.definition
    doc:  init: (ready) ->
      require.packages 'ckeditor4', =>
        @open.editor body.doc.firstChild, @opts, (cke) =>
          @ckeditor = cke
          @tabs.connect => @toolbar.connect =>
            body.tabs.inner.select 'Font'
            ready style: height: '100%'

class HtmlEditorView extends Integrant
  constructor: (@name, @host, @mvc, @opts) ->
  init: (ready) ->
      @mvc picture, @host, (err, body) =>
   
module.exports = HtmlEditorView