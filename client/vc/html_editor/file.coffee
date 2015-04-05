# Copyright (C) 2014 paul@marrington.net, see /GPL license
File = require 'client/model/File'

class File
  load: (@file_name) ->
    @file = new File(@file_name)
    @file.on 'error', =>
      @vc.ed.setData ''
      message "Flash: New Document"
    @file.read (data) => @vc.ed.setData data
    
  prepare: (@ed) ->
    save = => @file.save @vc.ed.getData()
    @vc.ed.on 'blur',   save
    @vc.ed.on 'change', save
    
module.exports = File