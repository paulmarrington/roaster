# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'client/Integrant'

class HtmlEditorView extends Integrant
  constructor: (@name, @host, @mvc, @opts) ->
  init: (ready) ->
    require.packages 'ckeditor4', =>
      @mvc 'panel_stack', @host, (err, body) =>
        @require 'tabs,toolbar,open', (err) =>
          body.add
            tabs: @tabs.definition
            doc:  style: height: '100%'
          @open.editor body.doc.firstChild, @opts, (cke) =>
            @ckeditor = cke
            @tabs.connect => @toolbar.connect =>
              body.tabs.inner.select 'Font'
              ready()
    
module.exports = HtmlEditorView