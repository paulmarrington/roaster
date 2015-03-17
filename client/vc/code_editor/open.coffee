# Copyright (C) 2015 paul@marrington.net, see /GPL for license
          
instance_index = 0

class Open
  editor: (@container) ->
    CodeMirror.modeURL =
      '/ext/codemirror/CodeMirror-master/mode/%N/%N.js'
    @vc.editor = CodeMirror @container, @options()
    @vc.editor.id = "codemirror_#{++instance_index}"

    allow_autocomplete = false

    @vc.editor.on 'changes', (cm, event) =>
      @save_in 1000
      # trigger auto-complete list on typing
      return if @vc.editor.somethingSelected()
      cursor = @vc.editor.doc.getCursor()
      line = @vc.editor.doc.getLine(cursor.line)
      if cursor.ch and allow_autocomplete
        if line[cursor.ch - 1].match(/\w/)
          CodeMirror.showHint(cm)

    @vc.editor.on 'keydown', (cm, event) ->
      allow_autocomplete = false

    @vc.editor.on 'keypress', (cm, event) ->
      char_code = event.which ? event.keyCode
      ch = String.fromCharCode(char_code)
      allow_autocomplete = true if ch.match(/\w/)

    @vc.editor.on 'blur', => @save_in 0
      
  save_in: (ms) ->
    clearTimeout @save_timer
    roaster.message "clear: saved"
    @save_timer = setTimeout (=> @vc.save()), ms
        
  options: ->
    return @_options if @_options
    if @_options = localStorage.CodeMirror_options
      @_options = JSON.parse(options)
    else
      @_options =
        lineNumbers:        true
        foldGutter:         true
#        gutters:            ["CodeMirror-lint-markers",
#                             "CodeMirror-foldgutter"]
        lint:               true
        matchBrackets:      true
        autoCloseBrackets:  true
        matchTags:          true
        showTrailingSpace:  true
        inputStyle:         "contenteditable"
        autofocus:          true
        dragDrop:           false
        cursorScrollMargin: 5
        scrollbarStyle:     'overlay'
        extraKeys:
          'Cmd-Left':         'goLineStartSmart'
          'Ctrl-Q':           'fold_at_cursor'
          'Ctrl-Space':       'autocomplete'
          'Ctrl-/':           'toggleComment'
          'Alt-<':            'goColumnLeft'
          'Alt->':            'goColumnRight'
          'Ctrl-Shift-F':     'clearSearch'
          'Alt-{':            'toMatchingTag'
          'Alt-S':            'view_source'
          'Ctrl-`':           'insertSoftTab'
          'Shift-Ctrl-`':     'insertTab'
          'Ctrl-,':           'delLineLeft'
          'Ctrl-.':           'killLine'
          'Shift-Ctrl-,':     'delWrappedLineLeft'
          'Shift-Ctrl-.':     'delWrappedLineRight'
          'Shift-Ctrl-Left':  'DelWordBefore'
          'Shift-Ctrl-Right': 'DelWordAfter'
          'Ctrl-Up':          'moveLinesUp'
          'Ctrl-Down':        'moveLinesDown'
          'Ctrl-Shift-T':     'transposeChars'
          'Ctrl-Left':        'goWordLeft'
          'Ctrl-Right':       'goWordRight'
          'Ctrl-Home':        'goLineLeft'
          'Ctrl-Shift-Home':  'goLineLeftSmart'
          'Ctrl-End':         'goLineRight'
     
module.exports = Open