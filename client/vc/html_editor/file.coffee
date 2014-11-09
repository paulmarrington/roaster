# Copyright (C) 2014 paul@marrington.net, see /GPL license
roaster = require 'roaster'; file = require 'client/file'

class File
  load: (@file_name) ->
    @file.read @file_name, (err, data) =>
      roaster.error "New Document" if err
    
  prepare: (@ed) ->
    @ed.on 'blur', save = => @save()
    @ed.on 'change', => file.on_change '*', save
    
  save: (done = ->) =>
    content = @ed.getData()
    file.write @file_name, content, (err, saved) ->
      return roaster.error(err) if err
      roaster.message('Saved') if saved
    
module.exports = File