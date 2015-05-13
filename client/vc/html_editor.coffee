# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

module.exports = class HtmlEditorView extends Integrant
  parse_host: ->
    if @child("html_editor").children.length is 0
      @wrap_inner(@host, 'html_editor')
    
  init: (ready) ->
    @require 'open,tabs,toolbar,file'
    @open.editor @child('doc'), ready
    
  link_action: (action) ->
    @ed.on 'contentDom', =>
      @ed.editable().on 'click', (event) =>
        return if not (a = $(event.data.$.target)).is('a')
        href = a.attr('href')
        if /^\w+(\/\w+)?$/.test(href)
          action(href)
        else
          window.open(href, '_blank')
        event.preventDefault?()
        event.cancel()