# Copyright (C) 2014 paul@marrington.net, see /GPL for license
dom = require 'dom'

default_options =
  height: "auto"
  fullPage: false
  autoGrow_onStartup: false
  resize_enabled: false
  magicline_putEverywhere: true
  allowedContent: true
  browserContextMenuOnCtrl: true
  scayt_autoStartup: false
  removeButtons: ''
  extraPlugins: 'tableresize,placeholder,widget,lineutils,find,'+
    'codeTag,ckeditor-gwf-plugin,leaflet,div,pagebreak,'+
    'codesnippet'

module.exports = class Open
  editor: (@container, ready) ->
    require.packages 'ckeditor', =>
      CKEDITOR.config.font_names += ';GoogleWebFonts'
      opts = [@vc.options]
      options = {}; opts.unshift default_options
      options[k] ?= v for k,v of o for o in opts
      @cke = CKEDITOR.appendTo @container, options
      @vc.ed = @cke
      @cke.on 'instanceReady', =>
        @vc.toolbar.prepare(@cke)
        @vc.file.prepare(@cke)
        @vc.tabs.prepare()
        @vc.adjust_height = =>
          @cke.container.hide()
          process.nextTick =>
            height = @container.parentNode.clientHeight
            @cke.container.show()
            @cke.resize '100%', height
        dom.resize_event @vc.adjust_height
        setTimeout (=> @vc.adjust_height()), 200
        @vc.tabs.select 'Font'
        @cke.focus()
        @vc.emit "html_editor_ready", @vc.ed
        @vc.tabs.view.reset_selection()
        ready()