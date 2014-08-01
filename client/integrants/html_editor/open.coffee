# Copyright (C) 2014 paul@marrington.net, see /GPL for license
requires = (ready) ->
  require.packages 'ckeditor4', => require 'dom', ready
  
default_options =
  fullPage: false
  autoGrow_onStartup: true
  resize_enabled: false
  magicline_putEverywhere: true
  allowedContent: true
  browserContextMenuOnCtrl: true
  scayt_autoStartup: false
  removeButtons: ''
  extraPlugins: 'tableresize,placeholder,widget,lineutils,find'

class Open  
  editor: (@host, ready) -> requires (imports) =>
    he = @host.walk('html_editor/..')
    opts = [he.integrant.options]
    options = {}; opts.unshift default_options
    options[k] ?= v for k,v of o for o in opts
    he.ckeditor = @cke = CKEDITOR.replace @host, options
    @cke.on 'instanceReady', =>
      @host.integrant.toolbar.prepare()
      @adjust_height()
      imports.dom.resize_event => @adjust_height()
      @host.walk('tabs/Font').select()
      ready()
  adjust_height: ->
    @cke.container.hide()
    process.nextTick =>
      height = @host.parentNode.clientHeight - 16
      @cke.container.show()
      @cke.resize '100%', height

module.exports = Open