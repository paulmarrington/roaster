# Copyright (C) 2015 paul@marrington.net, see /GPL license
File = require 'client/model/File'

module.exports = class HtmlFile
  load: (@file_name) ->
    @file = new File(@file_name)
    @file.on 'error', =>
      @vc.ed.setData ''
    @file.read (data) => @vc.ed.setData data
    
  prepare: (@ed) ->
    @vc.ed.on 'change', save = =>
      @file?.write @vc.ed.getData()
    @vc.ed.on 'blur', =>
      save()
      @file?.flush()