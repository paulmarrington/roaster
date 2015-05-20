# Copyright (C) 2015 paul@marrington.net, see /GPL license
File = require 'client/model/File'

module.exports = class HtmlFile
  load: (@file_name) ->
    @model = new File(@file_name)
    @model.service = @service if @service
    @model.on 'error', => @vc.ed.setData ''
    @model.read (data) => @vc.ed.setData data
    
  prepare: (@ed) ->
    @vc.ed.on 'change', save = =>
      @model?.write @vc.ed.getData()
    @vc.ed.on 'blur', =>
      save()
      @model?.flush()