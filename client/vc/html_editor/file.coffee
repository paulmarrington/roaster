# Copyright (C) 2015 paul@marrington.net, see /GPL license
File = require 'client/model/File'

module.exports = class HtmlFile
  save: -> @model?.write @vc.ed.getData()

  load: (file_name) ->
    @save()
    @vc.ed.setData ''
    @model = new File(@file_name = file_name, @service)
    @model.read (data) =>
      return if file_name isnt @file_name
      @vc.ed.setData(data)

  prepare: (@ed) ->
    @vc.ed.on 'change', =>
      clearTimeout(@change_timer) if @change_timer
      @change_timer = setTimeout (=> @save()), 2000
    @vc.ed.on 'blur', => @save(); @model?.flush()
