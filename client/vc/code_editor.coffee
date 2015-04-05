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
      
  load: (@filename, @model) ->
    meta = @mode.from_filename(@filename)
    lint = meta.mode in ['javascript', 'coffeescript']
    @editor.setOption 'lint', lint
    @editor.setOption 'mode', meta.mode
    CodeMirror.autoLoadMode(@editor, meta.mode)
    @ext = meta.ext
    @model.read (source) => @editor.setValue source
    save = => @model.save @vc.editor.getValue()
    @vc.editor.on 'blur',   save
    @vc.editor.on 'change', save

    
  contents: -> @editor.getValue()
   
module.exports = CodeEditorView