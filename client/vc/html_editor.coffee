# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

module.exports = class HtmlEditorView extends Integrant
  parse_host: ->
    if @child("html_editor").children.length is 0
      @wrap_inner(@host, 'html_editor')

  init: (ready) ->
    @require 'open,tabs,toolbar,file,select'
    @open.editor @child('doc'), =>
      @ed.on 'contentDom', =>
        @ed.editable().on 'click', (event) =>
          target = event.data.$.target
          return if not actions = @click_actions[target.nodeName]
          action(target) for action in actions
          event.preventDefault?()
          event.cancel()
      ready()

  click_actions: {}

  click_action: (node_names, action) -> # do something on click
    for name in node_names.split(',')
      @click_actions[name] ?= []
      @click_actions[name].push(action)
      @click_actions[name.toUpperCase()] = @click_actions[name]
