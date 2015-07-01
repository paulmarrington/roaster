# Copyright (C) 2015 paul@marrington.net, see /GPL license
File = require 'client/model/File'

module.exports = class HtmlFile
  save: -> @model?.write @vc.ed.getData()

  load: (file_name, on_loaded) ->
    @save()
    (model = new File(file_name, @service)).read (data) =>
      @model = model; @file_name = file_name
      @vc.ed.setData(data)
      on_loaded()

  prepare: (@ed) ->
    @vc.ed.on 'change', =>
      clearTimeout(@change_timer) if @change_timer
      @change_timer = setTimeout (=> @save()), 2000
    @vc.ed.on 'blur', => @save(); @model?.flush()
