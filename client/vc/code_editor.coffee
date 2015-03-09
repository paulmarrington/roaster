# Copyright (C) 2015 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class CodeEditorView extends Integrant
  parse_host: ->
    if @child("code_editor").children.length is 0
      @wrap_inner(@host, 'code_editor')
    
  init: (ready) ->
    require.packages 'codemirror', =>
      @require 'mode,commands,open,compile'
      @open.editor @child('doc')
      ready()
      
  load: (@filename, source) ->
    mode = @mode.from_filename(filename)
    lint = mode in ['javascript', 'coffeescript']
    @editor.setOption 'mode', mode
    CodeMirror.autoLoadMode(@editor, mode)
    @editor.setValue source
    
  contents: -> @editor.getValue()
    
  save: (source) -> # replaced my each instant
   
module.exports = CodeEditorView