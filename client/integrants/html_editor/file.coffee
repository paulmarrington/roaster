# Copyright (C) 2014 paul@marrington.net, see /GPL license
roaster = require 'roaster'

class File
  init: (@host) ->
    
  load: (@file_name) ->
    @file.read @file_name, (err, data) =>
      roaster.error "New Document" if err
    
  prepare: (@cke) ->
    @cke.on 'blur', save = => @save()
    require 'client/file', (imports) =>
      @file = imports.file
      @cke.on 'change', => @file.on_change '*', save
    
  save: (done = ->) =>
    content = @cke.getData()
    @file.write @file_name, content, (err, saved) ->
      return roaster.error(err) if err
      roaster.message('Saved') if saved
    
module.exports = File