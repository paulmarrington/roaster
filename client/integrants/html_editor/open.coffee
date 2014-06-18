# Copyright (C) 2014 paul@marrington.net, see /GPL for license

default_options =
  fullPage: true
  allowedContent: true
  browserContextMenuOnCtrl: true
  scayt_autoStartup: false
  removeButtons: ''
  extraPlugins: 'tableresize,placeholder,widget,lineutils,find'

class Open  
  init: (@integrant, ready) -> ready()
  editor: (container, opts..., ready) ->
    options = {}; opts.unshift default_options
    options[k] ?= v for k,v of opt for opt in opts
    ckeditor = CKEDITOR.replace container, options
    ckeditor.on 'instanceReady', ready

module.exports = Open
