# Copyright (C) 2015 paul@marrington.net, see /GPL license
Integrant = require 'vc/Integrant'

class CodeEditorView extends Integrant
  parse_host: ->
    if @child("code_editor").children.length is 0
      @wrap_inner(@host, 'code_editor')
    
  init: (ready) ->
    require.packages 'coffee-script', 'codemirror', =>
      @require 'context_menu,mode,commands,open,compile'
      @open.editor @child('code_editor')
      @context_menu.prepare(@child('menu_icon'))
      ready()
      
  load: (@filename, source) ->
    mode = @mode.from_filename(@filename)
    lint = mode in ['javascript', 'coffeescript']
    @editor.setOption 'mode', mode
    CodeMirror.autoLoadMode(@editor, mode)
    @editor.setValue source
    
  contents: -> @editor.getValue()
    
  save: (source) -> # replaced my each instant
   
module.exports = CodeEditorView