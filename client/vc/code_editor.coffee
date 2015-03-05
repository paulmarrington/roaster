# Copyright (C) 2015 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class CodeEditorView extends Integrant
  parse_host: ->
    if @child("code_editor").children.length is 0
      @wrap_inner(@host, 'code_editor')
    
  init: (ready) ->
    @require 'open'
    @open.editor @child('doc'), ready
   
module.exports = CodeEditorView